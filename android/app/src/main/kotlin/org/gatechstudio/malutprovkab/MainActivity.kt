package org.gatechstudio.malutprovkab

import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private val saluran = "bakudapa/keamanan"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, saluran)
            .setMethodCallHandler { panggilan, hasil ->
                when (panggilan.method) {
                    "debuggerTerpasang" ->
                        hasil.success(DeteksiKeamanan.debuggerTerpasang(applicationContext))
                    "fridaTerdeteksi" ->
                        hasil.success(DeteksiKeamanan.fridaTerdeteksi())
                    "rootTerdeteksi" ->
                        hasil.success(DeteksiKeamanan.rootTerdeteksi(applicationContext))
                    "emulatorTerdeteksi" ->
                        hasil.success(DeteksiKeamanan.emulatorTerdeteksi())
                    "sidikTandaTangan" ->
                        hasil.success(DeteksiKeamanan.sidikTandaTangan(applicationContext))
                    "kunciBlob" -> {
                        val k = Kepemilikan.kunciBlob()
                        hasil.success(if (k.isEmpty()) null else k)
                    }
                    "amankanLayarOn" -> {
                        runOnUiThread {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        hasil.success(true)
                    }
                    "amankanLayarOff" -> {
                        runOnUiThread {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        hasil.success(true)
                    }
                    else -> hasil.notImplemented()
                }
            }
    }
}
