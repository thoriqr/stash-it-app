package id.my.thoriqr.stashit

import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private var installerChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        sharedEngine = flutterEngine

        installerChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            INSTALLER_CHANNEL,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "openApk" -> openApk(call.argument<String>("path"), result)
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        installerChannel?.setMethodCallHandler(null)
        installerChannel = null
        if (sharedEngine === flutterEngine) {
            sharedEngine = null
        }
        super.cleanUpFlutterEngine(flutterEngine)
    }

    /**
     * Hands a verified APK from the app's update cache to the system package
     * installer. The path is constrained to [cacheDir]/updates, and the system
     * installer still asks the user to approve the install.
     */
    private fun openApk(path: String?, result: MethodChannel.Result) {
        Log.d(TAG, "openApk requested path=$path")

        if (path.isNullOrBlank()) {
            Log.e(TAG, "openApk rejected: missing path")
            result.error("invalid_path", "The APK path is missing.", null)
            return
        }

        val file: File
        val updatesDir: File
        try {
            file = File(path).canonicalFile
            updatesDir = File(cacheDir, "updates").canonicalFile
        } catch (error: Exception) {
            Log.e(TAG, "openApk rejected: canonical path failed", error)
            result.error("invalid_path", error.message, null)
            return
        }

        val insideUpdatesDir = file.path.startsWith(updatesDir.path + File.separator)
        Log.d(
            TAG,
            "openApk path=${file.path} exists=${file.isFile} size=${file.length()} " +
                "updatesDir=${updatesDir.path} inside=$insideUpdatesDir",
        )

        if (
            !insideUpdatesDir ||
            !file.isFile ||
            !file.name.endsWith(".apk", ignoreCase = true)
        ) {
            Log.e(TAG, "openApk rejected: file is not a cached APK")
            result.error(
                "invalid_path",
                "The APK is not inside the update cache.",
                null,
            )
            return
        }

        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            !packageManager.canRequestPackageInstalls()
        ) {
            Log.w(TAG, "openApk blocked: REQUEST_INSTALL_PACKAGES is not allowed")
            val settingsIntent = Intent(
                Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                Uri.parse("package:$packageName"),
            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            try {
                startActivity(settingsIntent)
                Log.i(TAG, "openApk opened install-unknown-apps settings")
            } catch (error: ActivityNotFoundException) {
                Log.e(
                    TAG,
                    "openApk failed: install-unknown-apps settings unavailable",
                    error,
                )
            }
            result.error(
                "install_permission_required",
                "Allow Stash-it to install unknown apps, then try again.",
                null,
            )
            return
        }

        try {
            val uri = FileProvider.getUriForFile(this, "$packageName.updates", file)
            Log.d(TAG, "openApk providerUri=$uri")
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "application/vnd.android.package-archive")
                clipData = ClipData.newRawUri("", uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            Log.i(TAG, "openApk installer intent opened")
            result.success(true)
        } catch (error: ActivityNotFoundException) {
            Log.e(TAG, "openApk failed: no package installer", error)
            result.error("no_installer", "No package installer is available.", null)
        } catch (error: Exception) {
            Log.e(TAG, "openApk failed: installer intent", error)
            result.error("install_failed", error.message, null)
        }
    }

    companion object {
        private const val TAG = "StashItInstaller"
        private const val INSTALLER_CHANNEL = "stash_it/installer"

        /**
         * The live UI engine, while its activity still owns it.
         *
         * The transparent ShareActivity prefers this engine so a share uses the
         * same Dart isolate, session controller and serialized refresh path as
         * the rest of the app. A second engine is created only when this is null
         * (the app process has no UI engine), which avoids two owners of the
         * rotating refresh token.
         */
        @Volatile
        var sharedEngine: FlutterEngine? = null
    }
}
