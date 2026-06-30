package org.gatechstudio.malutprovkab

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Debug
import java.io.File
import java.net.InetSocketAddress
import java.net.Socket
import java.security.MessageDigest

object DeteksiKeamanan {

    private val portaFrida = intArrayOf(27042, 27043)

    private val jejakFrida = listOf(
        "frida", "frida-server", "frida-agent", "frida-gadget", "gum-js-loop",
        "gmain", "linjector", "re.frida.server",
    )

    private val berkasInjeksi = listOf(
        "/data/local/tmp/frida-server",
        "/data/local/tmp/re.frida.server",
        "/data/local/tmp/frida-gadget",
        "/sbin/magisk",
        "/system/bin/magisk",
        "/data/adb/magisk",
        "/data/adb/lspd",
        "/system/framework/XposedBridge.jar",
        "/system/bin/app_process_xposed",
    )

    private val jalurSu = listOf(
        "/system/bin/su",
        "/system/xbin/su",
        "/sbin/su",
        "/system/su",
        "/system/bin/.ext/.su",
        "/system/usr/we-need-root/su-backup",
        "/system/xbin/mu",
        "/su/bin/su",
        "/magisk/.core/bin/su",
        "/data/local/xbin/su",
        "/data/local/bin/su",
        "/data/local/su",
        "/vendor/bin/su",
    )

    private val berkasRoot = listOf(
        "/system/app/Superuser.apk",
        "/system/etc/init.d/99SuperSUDaemon",
        "/dev/com.koushikdutta.superuser.daemon/",
        "/system/xbin/daemonsu",
        "/data/adb/magisk.db",
        "/data/adb/ksu",
        "/data/adb/ap",
        "/cache/.disable_magisk",
        "/sbin/.magisk",
    )

    private val paketRoot = listOf(
        "com.topjohnwu.magisk",
        "com.noshufou.android.su",
        "com.noshufou.android.su.elite",
        "eu.chainfire.supersu",
        "com.koushikdutta.superuser",
        "com.thirdparty.superuser",
        "com.yellowes.su",
        "com.kingroot.kinguser",
        "com.kingo.root",
        "com.smedialink.oneclickroot",
        "com.zhiqupk.root.global",
        "com.alephzain.framaroot",
        "de.robv.android.xposed.installer",
        "org.lsposed.manager",
    )

    private val jalurSistemTulis = listOf(
        "/system", "/system/bin", "/system/sbin", "/system/xbin",
        "/vendor/bin", "/sbin", "/etc",
    )

    private val berkasEmulator = listOf(
        "/dev/socket/qemud",
        "/dev/qemu_pipe",
        "/system/lib/libc_malloc_debug_qemu.so",
        "/sys/qemu_trace",
        "/system/bin/qemu-props",
        "/dev/socket/genyd",
        "/dev/socket/baseband_genyd",
        "/system/bin/microvirt-prop",
        "/system/lib/libdroid4x.so",
        "/system/bin/windroyed",
        "/system/bin/nox-prop",
        "/ueventd.android_x86.rc",
        "/x86.prop",
        "/ueventd.ttVM_x86.rc",
        "/init.ttVM_x86.rc",
    )

    fun debuggerTerpasang(context: Context): Boolean {
        val flagDebuggable =
            (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        return flagDebuggable || Debug.isDebuggerConnected() || Debug.waitingForDebugger()
    }

    fun fridaTerdeteksi(): Boolean {
        if (portaFridaTerbuka()) return true
        if (adaBerkas(berkasInjeksi)) return true
        if (pustakaInjeksiTermuat()) return true
        return false
    }

    fun rootTerdeteksi(context: Context): Boolean {
        if (Build.TAGS?.contains("test-keys") == true) return true
        if (adaBerkas(jalurSu)) return true
        if (adaBerkas(berkasRoot)) return true
        if (suBisaDieksekusi()) return true
        if (paketRootTerpasang(context)) return true
        if (jalurSistemDapatDitulis()) return true
        return false
    }

    fun emulatorTerdeteksi(): Boolean {
        if (adaBerkas(berkasEmulator)) return true
        return Build.FINGERPRINT.startsWith("generic") ||
            Build.FINGERPRINT.startsWith("unknown") ||
            Build.FINGERPRINT.contains("vbox") ||
            Build.FINGERPRINT.contains("test-keys") ||
            Build.MODEL.contains("google_sdk") ||
            Build.MODEL.contains("Emulator") ||
            Build.MODEL.contains("Android SDK built for x86") ||
            Build.MODEL.contains("sdk_gphone") ||
            Build.MANUFACTURER.contains("Genymotion") ||
            (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")) ||
            Build.PRODUCT.contains("sdk") ||
            Build.PRODUCT.contains("vbox86p") ||
            Build.PRODUCT.contains("emulator") ||
            Build.PRODUCT.contains("simulator") ||
            Build.HARDWARE.contains("goldfish") ||
            Build.HARDWARE.contains("ranchu") ||
            Build.HARDWARE.contains("vbox86")
    }

    fun sidikTandaTangan(context: Context): String? {
        return try {
            val pm = context.packageManager
            val sertifikat = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val info = pm.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES,
                )
                val penanda = info.signingInfo ?: return null
                if (penanda.hasMultipleSigners()) {
                    penanda.apkContentsSigners
                } else {
                    penanda.signingCertificateHistory
                }
            } else {
                @Suppress("DEPRECATION")
                val info = pm.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNATURES,
                )
                @Suppress("DEPRECATION")
                info.signatures
            }
            val pertama = sertifikat?.firstOrNull() ?: return null
            val pencerna = MessageDigest.getInstance("SHA-256")
            pencerna.update(pertama.toByteArray())
            pencerna.digest().joinToString("") { "%02x".format(it) }
        } catch (_: Exception) {
            null
        }
    }

    private fun portaFridaTerbuka(): Boolean {
        for (porta in portaFrida) {
            try {
                Socket().use { soket ->
                    soket.connect(InetSocketAddress("127.0.0.1", porta), 180)
                    return true
                }
            } catch (_: Exception) {
            }
        }
        return false
    }

    private fun pustakaInjeksiTermuat(): Boolean {
        return try {
            File("/proc/self/maps").useLines { baris ->
                baris.any { garis ->
                    val kecil = garis.lowercase()
                    jejakFrida.any { kecil.contains(it) }
                }
            }
        } catch (_: Exception) {
            false
        }
    }

    private fun suBisaDieksekusi(): Boolean {
        return try {
            val proses = Runtime.getRuntime().exec(arrayOf("which", "su"))
            val keluaran = proses.inputStream.bufferedReader().use { it.readLine() }
            proses.destroy()
            !keluaran.isNullOrEmpty()
        } catch (_: Exception) {
            false
        }
    }

    private fun paketRootTerpasang(context: Context): Boolean {
        val pm = context.packageManager
        return paketRoot.any { paket ->
            try {
                pm.getPackageInfo(paket, 0)
                true
            } catch (_: Exception) {
                false
            }
        }
    }

    private fun jalurSistemDapatDitulis(): Boolean = jalurSistemTulis.any {
        try {
            File(it).canWrite()
        } catch (_: Exception) {
            false
        }
    }

    private fun adaBerkas(daftar: List<String>): Boolean = daftar.any {
        try {
            File(it).exists()
        } catch (_: Exception) {
            false
        }
    }
}
