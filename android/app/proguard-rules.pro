-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

-keep class androidx.lifecycle.** { *; }
-keep class androidx.fragment.app.** { *; }
-dontwarn androidx.**

-keep class kotlin.Metadata { *; }
-keep class kotlin.reflect.** { *; }
-keepclassmembers class kotlin.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**

-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_** { *; }
-keep class com.google.android.gms.vision.** { *; }
-keep class com.google.android.odml.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**

-keep class io.flutter.plugins.camera.** { *; }
-keep class io.flutter.plugins.camerax.** { *; }
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

-keep class com.llfbandit.record.** { *; }
-dontwarn com.llfbandit.record.**

-keep class io.flutter.plugins.localauth.** { *; }
-keep class androidx.biometric.** { *; }
-dontwarn androidx.biometric.**

-keep class com.example.safe_device.** { *; }
-dontwarn com.example.safe_device.**

-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keepclassmembers class com.it_nomads.fluttersecurestorage.** { *; }

-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class com.mr.flutter.plugin.filepicker.** { *; }

-keep class io.flutter.plugins.pathprovider.** { *; }

-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes Exceptions

-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

-keepclasseswithmembernames class * {
    native <methods>;
}

-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

-assumenosideeffects class android.util.Log {
    public static *** v(...);
    public static *** d(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

-optimizationpasses 5
-allowaccessmodification
-mergeinterfacesaggressively
-repackageclasses ''
-overloadaggressively

-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable
