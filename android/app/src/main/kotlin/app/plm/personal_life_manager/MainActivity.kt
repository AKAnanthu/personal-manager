package app.plm.personal_life_manager

import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.PersistableBundle
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FragmentActivity is required by local_auth (BiometricPrompt).
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Android 13+: show a blank thumbnail in Recents for every screen.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            setRecentsScreenshotEnabled(false)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.plm/platform")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // FLAG_SECURE blocks screenshots, screen recording and the
                    // Recents thumbnail while a sensitive screen is visible.
                    "setSecure" -> {
                        if (call.arguments == true) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(null)
                    }
                    "excludeFromBackup" -> result.success(null) // manifest handles Android
                    "copySensitive" -> {
                        val text = call.argument<String>("text") ?: ""
                        val seconds = call.argument<Int>("seconds") ?: 30
                        copySensitive(text, seconds.toLong())
                        result.success(null)
                    }
                    "openNotificationSettings" -> {
                        startActivity(
                            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                                .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                        )
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /// Marks the clip sensitive (hidden from the Android 13+ clipboard
    /// preview) and clears it after [seconds] if it is still this clip.
    private fun copySensitive(text: String, seconds: Long) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText(CLIP_LABEL, text)
        clip.description.extras = PersistableBundle().apply {
            putBoolean(ClipDescription.EXTRA_IS_SENSITIVE, true)
        }
        clipboard.setPrimaryClip(clip)
        Handler(Looper.getMainLooper()).postDelayed({
            // In the background the description may be unreadable (null);
            // clear then too rather than leave a password behind.
            val current = clipboard.primaryClipDescription
            if (current == null || current.label == CLIP_LABEL) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    clipboard.clearPrimaryClip()
                } else {
                    clipboard.setPrimaryClip(ClipData.newPlainText("", ""))
                }
            }
        }, seconds * 1000)
    }

    private companion object {
        const val CLIP_LABEL = "plm-sensitive"
    }
}
