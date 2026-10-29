package id.my.thoriqr.stashit

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        sharedEngine = flutterEngine
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        if (sharedEngine === flutterEngine) {
            sharedEngine = null
        }
        super.cleanUpFlutterEngine(flutterEngine)
    }

    companion object {
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
