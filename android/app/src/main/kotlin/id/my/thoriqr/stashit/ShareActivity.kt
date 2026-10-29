package id.my.thoriqr.stashit

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayDeque

/**
 * Invisible Android share target.
 *
 * It never calls [setContentView] and never renders Flutter. The activity is
 * transparent, sits in its own task, and finishes as soon as the queued shares
 * settle, so selecting Stash-it in the share sheet does not open the app.
 *
 * The save itself runs in Dart through the existing repository and auth
 * interceptor:
 *
 * - if the live UI engine is alive, its channel handler is used, so the live
 *   SessionController remains the only owner of refresh-token rotation;
 * - otherwise a headless engine runs `shareIntakeMain` from `main.dart`.
 *
 * Kotlin contains no API, DTO, token, or refresh logic.
 */
class ShareActivity : Activity() {
    private val queue = ArrayDeque<String>()
    private val queued = mutableSetOf<String>()
    private val handler = Handler(Looper.getMainLooper())

    private var current: String? = null
    private var processing = false
    private var watchdog: Runnable? = null
    private var pingTimeout: Runnable? = null

    private var headlessEngine: FlutterEngine? = null
    private var headlessChannel: MethodChannel? = null
    private var headlessReady = false
    private var pendingHeadlessText: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // A recreated activity must not process the same share a second time.
        if (savedInstanceState != null) {
            finish()
            return
        }

        enqueue(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        enqueue(intent)
    }

    override fun onDestroy() {
        cancelWatchdog()
        cancelPingTimeout()
        headlessChannel?.setMethodCallHandler(null)
        headlessChannel = null
        headlessEngine?.destroy()
        headlessEngine = null
        super.onDestroy()
    }

    private fun enqueue(intent: Intent?) {
        val text = intent?.getStringExtra(Intent.EXTRA_TEXT)
            ?: intent?.clipData?.getItemAt(0)?.text?.toString()
        val trimmed = text?.trim().orEmpty()

        if (trimmed.isEmpty()) {
            if (!processing) finish()
            return
        }

        // A duplicate of the share already being handled, or already queued, is
        // ignored. Different URLs are never equal and remain separate work.
        if (trimmed == current || queued.contains(trimmed)) return

        queue.addLast(trimmed)
        queued.add(trimmed)
        if (!processing) processNext()
    }

    private fun processNext() {
        val text = queue.pollFirst()
        if (text == null) {
            finishAll()
            return
        }

        queued.remove(text)
        current = text
        processing = true
        armWatchdog()

        val live = MainActivity.sharedEngine
        if (live != null) {
            invokeOnLiveEngine(live, text)
        } else {
            startHeadless(text)
        }
    }

    /**
     * Prefers the live UI isolate. A `ping` confirms the Dart handler is
     * registered before the share is sent; a missing handler or a refused call
     * falls back to the headless engine.
     */
    private fun invokeOnLiveEngine(engine: FlutterEngine, text: String) {
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        var answered = false

        val timeout = Runnable {
            if (answered) return@Runnable
            answered = true
            pingTimeout = null
            // No share has reached the live engine, so starting the headless
            // path here cannot duplicate a remote write.
            startHeadless(text)
        }
        pingTimeout = timeout
        handler.postDelayed(timeout, PING_TIMEOUT_MS)

        channel.invokeMethod("ping", null, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (answered) return
                answered = true
                cancelPingTimeout()
                if (result == true) {
                    dispatch(channel, text)
                } else {
                    startHeadless(text)
                }
            }

            override fun error(
                errorCode: String,
                errorMessage: String?,
                errorDetails: Any?,
            ) {
                if (answered) return
                answered = true
                cancelPingTimeout()
                startHeadless(text)
            }

            override fun notImplemented() {
                if (answered) return
                answered = true
                cancelPingTimeout()
                startHeadless(text)
            }
        })
    }

    private fun startHeadless(text: String) {
        val existing = headlessEngine
        if (existing != null) {
            if (headlessReady) {
                dispatch(headlessChannel!!, text)
            } else {
                pendingHeadlessText = text
            }
            return
        }

        val engine = FlutterEngine(applicationContext)
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        headlessEngine = engine
        headlessChannel = channel
        headlessReady = false
        pendingHeadlessText = text

        channel.setMethodCallHandler { call, result ->
            if (call.method == "ready") {
                headlessReady = true
                result.success(null)
                val pending = pendingHeadlessText
                pendingHeadlessText = null
                if (pending != null) {
                    dispatch(channel, pending)
                }
            } else {
                result.notImplemented()
            }
        }

        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(
                "shareIntakeMain",
                "package:stash_it_app/main.dart",
            ),
        )
    }

    private fun dispatch(channel: MethodChannel, text: String) {
        channel.invokeMethod("handleShare", text, object : MethodChannel.Result {
            override fun success(result: Any?) {
                val map = result as? Map<*, *>
                val message = map?.get("message") as? String
                val outcome = map?.get("outcome") as? String
                showToast(message, outcome)
                done()
            }

            override fun error(
                errorCode: String,
                errorMessage: String?,
                errorDetails: Any?,
            ) {
                // The share has already been handed to an engine. Retrying it
                // through the other engine could create a second remote item, so
                // this is terminal. The ping gate is the only fallback point.
                showGenericFailure()
                done()
            }

            override fun notImplemented() {
                showGenericFailure()
                done()
            }
        })
    }

    private fun done() {
        cancelWatchdog()
        cancelPingTimeout()
        current = null
        processing = false

        if (queue.isEmpty()) {
            finishAll()
        } else {
            processNext()
        }
    }

    private fun finishAll() {
        cancelWatchdog()
        cancelPingTimeout()
        headlessChannel?.setMethodCallHandler(null)
        // The Dart side disposes its container on `shutdown`; destroying the
        // engine straight after is still safe because teardown reclaims the
        // isolate. The call is best-effort and has no result callback.
        headlessChannel?.invokeMethod("shutdown", null)
        headlessEngine?.destroy()
        headlessChannel = null
        headlessEngine = null
        headlessReady = false
        pendingHeadlessText = null
        current = null
        processing = false

        if (!isFinishing) finish()
    }

    private fun armWatchdog() {
        cancelWatchdog()
        val runnable = Runnable {
            showGenericFailure()
            finishAll()
        }
        watchdog = runnable
        handler.postDelayed(runnable, WATCHDOG_MS)
    }

    private fun cancelWatchdog() {
        val runnable = watchdog ?: return
        handler.removeCallbacks(runnable)
        watchdog = null
    }

    private fun cancelPingTimeout() {
        val runnable = pingTimeout ?: return
        handler.removeCallbacks(runnable)
        pingTimeout = null
    }

    private fun showToast(message: String?, outcome: String?) {
        if (message.isNullOrBlank() || outcome == "ignored") return
        val length = if (outcome == "saved" || outcome == "invalid") {
            Toast.LENGTH_SHORT
        } else {
            Toast.LENGTH_LONG
        }
        Toast.makeText(applicationContext, message, length).show()
    }

    private fun showGenericFailure() {
        Toast.makeText(
            applicationContext,
            "Stash-it couldn't finish saving that link.",
            Toast.LENGTH_LONG,
        ).show()
    }

    private companion object {
        const val CHANNEL = "stash_it/share_intake"
        const val PING_TIMEOUT_MS = 2_000L
        const val WATCHDOG_MS = 45_000L
    }
}
