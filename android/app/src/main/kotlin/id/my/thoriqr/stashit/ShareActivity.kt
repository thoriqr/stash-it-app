package id.my.thoriqr.stashit

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Typeface
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * Visible Android share target.
 *
 * A small dialog-style card shows the shared link, an optional note, and the
 * Save/Cancel actions. It sits in its own task, so it never opens the app's
 * main UI, and it finishes itself after the save.
 *
 * The save itself runs in Dart through the existing repository and auth
 * interceptor:
 *
 * - if the live UI engine is alive, its channel handler is used, so the live
 *   SessionController remains the only owner of refresh-token rotation;
 * - otherwise a headless engine runs `shareIntakeMain` from `main.dart`.
 *
 * Kotlin contains no API, DTO, token, or refresh logic. The card only collects
 * the note and shows the outcome; Dart writes the URL to the device-local list
 * before the request, so a dismissed or failed save still keeps the link.
 */
class ShareActivity : Activity() {
    private val handler = Handler(Looper.getMainLooper())

    private lateinit var urlView: TextView
    private lateinit var noteView: EditText
    private lateinit var statusView: TextView
    private lateinit var eyebrowView: TextView
    private lateinit var titleView: TextView
    private lateinit var noteLabelView: TextView
    private lateinit var saveButton: Button
    private lateinit var cancelButton: Button
    private var neutralStatusColor: Int = 0

    private var shareText: String? = null
    private var processing = false
    private var watchdog: Runnable? = null
    private var pingTimeout: Runnable? = null
    private var finishRunnable: Runnable? = null

    private var headlessEngine: FlutterEngine? = null
    private var headlessChannel: MethodChannel? = null
    private var headlessReady = false
    private var pendingHeadlessText: String? = null
    private var pendingHeadlessNote: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // A recreated activity must not process the same share a second time.
        if (savedInstanceState != null) {
            finish()
            return
        }

        setContentView(R.layout.activity_share_card)
        setFinishOnTouchOutside(true)

        urlView = findViewById(R.id.share_url)
        noteView = findViewById(R.id.share_note)
        statusView = findViewById(R.id.share_status)
        eyebrowView = findViewById(R.id.share_eyebrow)
        titleView = findViewById(R.id.share_title)
        noteLabelView = findViewById(R.id.share_note_label)
        saveButton = findViewById(R.id.share_save)
        cancelButton = findViewById(R.id.share_cancel)
        neutralStatusColor = statusView.currentTextColor
        applyTypefaces()

        saveButton.setOnClickListener { save() }
        cancelButton.setOnClickListener { finish() }

        val text = shareTextFrom(intent)
        if (text == null) {
            finish()
            return
        }
        showShare(text)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        // While a save is running the card keeps its current link. A later share
        // starts a fresh card instead of replacing the note being typed.
        if (processing) return

        val text = shareTextFrom(intent) ?: return
        if (text == shareText) return
        showShare(text)
    }

    override fun onDestroy() {
        cancelWatchdog()
        cancelPingTimeout()
        cancelScheduledFinish()
        teardownEngine()
        super.onDestroy()
    }

    private fun shareTextFrom(intent: Intent?): String? {
        val text = intent?.getStringExtra(Intent.EXTRA_TEXT)
            ?: intent?.clipData?.getItemAt(0)?.text?.toString()
        return text?.trim()?.takeIf { it.isNotEmpty() }
    }

    private fun showShare(text: String) {
        cancelScheduledFinish()

        shareText = text
        urlView.text = text
        noteView.setText("")
        noteView.isEnabled = true
        statusView.visibility = View.GONE
        statusView.setTextColor(neutralStatusColor)
        saveButton.visibility = View.VISIBLE
        saveButton.isEnabled = true
        saveButton.setText(R.string.share_card_save)
        cancelButton.visibility = View.VISIBLE
        cancelButton.isEnabled = true

        // Keep the note field from opening the keyboard immediately.
        findViewById<View>(R.id.share_card_root).requestFocus()
    }

    private fun save() {
        if (processing) return
        val text = shareText ?: return

        hideKeyboard()
        processing = true
        saveButton.isEnabled = false
        noteView.isEnabled = false
        statusView.setTextColor(neutralStatusColor)
        statusView.setText(R.string.share_card_saving)
        statusView.visibility = View.VISIBLE

        val note = noteView.text?.toString()?.trim()?.takeIf { it.isNotEmpty() }
        armWatchdog()

        val live = MainActivity.sharedEngine
        if (live != null) {
            invokeOnLiveEngine(live, text, note)
        } else {
            startHeadless(text, note)
        }
    }

    /**
     * Prefers the live UI isolate. A `ping` confirms the Dart handler is
     * registered before the share is sent; a missing handler or a refused call
     * falls back to the headless engine.
     */
    private fun invokeOnLiveEngine(
        engine: FlutterEngine,
        text: String,
        note: String?,
    ) {
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        var answered = false

        val timeout = Runnable {
            if (answered) return@Runnable
            answered = true
            pingTimeout = null
            // No share has reached the live engine, so starting the headless
            // path here cannot duplicate a remote write.
            startHeadless(text, note)
        }
        pingTimeout = timeout
        handler.postDelayed(timeout, PING_TIMEOUT_MS)

        channel.invokeMethod("ping", null, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (answered) return
                answered = true
                cancelPingTimeout()
                if (result == true) {
                    dispatch(channel, text, note)
                } else {
                    startHeadless(text, note)
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
                startHeadless(text, note)
            }

            override fun notImplemented() {
                if (answered) return
                answered = true
                cancelPingTimeout()
                startHeadless(text, note)
            }
        })
    }

    private fun startHeadless(text: String, note: String?) {
        val existing = headlessEngine
        if (existing != null) {
            if (headlessReady) {
                dispatch(headlessChannel!!, text, note)
            } else {
                pendingHeadlessText = text
                pendingHeadlessNote = note
            }
            return
        }

        val engine = FlutterEngine(applicationContext)
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        headlessEngine = engine
        headlessChannel = channel
        headlessReady = false
        pendingHeadlessText = text
        pendingHeadlessNote = note

        channel.setMethodCallHandler { call, result ->
            if (call.method == "ready") {
                headlessReady = true
                result.success(null)
                val pending = pendingHeadlessText
                val pendingNote = pendingHeadlessNote
                pendingHeadlessText = null
                pendingHeadlessNote = null
                if (pending != null) {
                    dispatch(channel, pending, pendingNote)
                }
            } else {
                result.notImplemented()
            }
        }

        engine.dartExecutor.executeDartEntrypoint(
            // The three-argument overload is (bundle path, entrypoint library,
            // entrypoint function). The two-argument overload is (bundle path,
            // function name), which leaves the library unset and the entrypoint
            // unresolved.
            DartExecutor.DartEntrypoint(
                FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                "package:stash_it_app/main.dart",
                "shareIntakeMain",
            ),
        )
    }

    private fun dispatch(channel: MethodChannel, text: String, note: String?) {
        val payload = mapOf("text" to text, "note" to note)
        channel.invokeMethod("handleShare", payload, object : MethodChannel.Result {
            override fun success(result: Any?) {
                handleOutcome(result)
            }

            override fun error(
                errorCode: String,
                errorMessage: String?,
                errorDetails: Any?,
            ) {
                // The share has already been handed to an engine. Retrying it
                // through the other engine could create a second remote item, so
                // this is terminal. The ping gate is the only fallback point.
                showTerminalFailure()
            }

            override fun notImplemented() {
                showTerminalFailure()
            }
        })
    }

    private fun handleOutcome(result: Any?) {
        cancelWatchdog()
        processing = false
        teardownEngine()

        if (isFinishing || isDestroyed) return

        val map = result as? Map<*, *>
        val message = map?.get("message") as? String
        val outcome = map?.get("outcome") as? String

        when (outcome) {
            "ignored" -> {
                finishAll()
                return
            }

            "saved" -> {
                statusView.setTextColor(getColor(R.color.share_success))
                statusView.text = message?.takeIf { it.isNotBlank() }
                    ?: getString(R.string.share_card_saved)
                statusView.visibility = View.VISIBLE
                saveButton.visibility = View.GONE
                cancelButton.visibility = View.GONE
                scheduleFinish(600L)
            }

            else -> {
                // A kept-on-device outcome is a warning; a rejection or an
                // unreadable result is a known failure.
                statusView.setTextColor(
                    getColor(
                        when (outcome) {
                            "storedAfterFailure", "storedAfterUncertain" ->
                                R.color.share_warning
                            else -> R.color.share_danger
                        },
                    ),
                )
                statusView.text = message?.takeIf { it.isNotBlank() }
                    ?: getString(R.string.share_save_failed)
                statusView.visibility = View.VISIBLE
                saveButton.visibility = View.GONE
                cancelButton.visibility = View.GONE
                scheduleFinish(1800L)
            }
        }
    }

    private fun showTerminalFailure() {
        cancelWatchdog()
        processing = false
        teardownEngine()

        if (isFinishing || isDestroyed) return

        statusView.setTextColor(getColor(R.color.share_danger))
        statusView.setText(R.string.share_save_failed)
        statusView.visibility = View.VISIBLE
        saveButton.visibility = View.GONE
        cancelButton.visibility = View.GONE
        scheduleFinish(1800L)
    }

    private fun scheduleFinish(delayMs: Long) {
        cancelScheduledFinish()
        val runnable = Runnable { finishAll() }
        finishRunnable = runnable
        handler.postDelayed(runnable, delayMs)
    }

    private fun finishAll() {
        cancelWatchdog()
        cancelPingTimeout()
        cancelScheduledFinish()
        teardownEngine()
        if (!isFinishing) finish()
    }

    private fun teardownEngine() {
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
        pendingHeadlessNote = null
    }

    private fun armWatchdog() {
        cancelWatchdog()
        val runnable = Runnable { showTerminalFailure() }
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

    private fun cancelScheduledFinish() {
        val runnable = finishRunnable ?: return
        handler.removeCallbacks(runnable)
        finishRunnable = null
    }

    private fun hideKeyboard() {
        val manager = getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
        manager?.hideSoftInputFromWindow(noteView.windowToken, 0)
    }

    private fun applyTypefaces() {
        eyebrowView.typeface = displayTypeface
        titleView.typeface = interBoldTypeface
        noteLabelView.typeface = displayTypeface
        urlView.typeface = monoTypeface
        noteView.typeface = interTypeface
        statusView.typeface = interTypeface
        cancelButton.typeface = interBoldTypeface
        saveButton.typeface = interBoldTypeface
    }

    /**
     * Loads a font bundled with the Flutter assets.
     *
     * A missing asset must not break the card, so the platform font is kept as
     * the fallback.
     */
    private fun assetTypeface(file: String): Typeface? = try {
        Typeface.createFromAsset(assets, "flutter_assets/assets/fonts/$file")
    } catch (_: Exception) {
        null
    }

    private val interTypeface: Typeface? by lazy { assetTypeface("inter-var.ttf") }
    private val interBoldTypeface: Typeface? by lazy {
        interTypeface?.let { Typeface.create(it, Typeface.BOLD) }
    }
    private val monoTypeface: Typeface? by lazy { assetTypeface("jbmono-var.ttf") }
    private val displayTypeface: Typeface? by lazy {
        assetTypeface("silkscreen-700.ttf")
    }

    private companion object {
        const val CHANNEL = "stash_it/share_intake"
        const val PING_TIMEOUT_MS = 2_000L
        const val WATCHDOG_MS = 45_000L
    }
}
