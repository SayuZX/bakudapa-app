package org.gatechstudio.malutprovkab

object Kepemilikan {

    private var nativeTersedia: Boolean = false

    init {
        nativeTersedia = if (BuildConfig.SIMULASI_TANPA_NATIVE) {
            false
        } else {
            try {
                System.loadLibrary("kepemilikan")
                true
            } catch (_: Throwable) {
                false
            }
        }
    }

    private external fun kunciBlobNative(): String

    fun kunciBlob(): String {
        if (!nativeTersedia) return ""
        return try {
            kunciBlobNative()
        } catch (_: Throwable) {
            ""
        }
    }
}
