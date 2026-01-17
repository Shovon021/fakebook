# Flutter ProGuard Rules
# Keep Flutter wrappers
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Cloudinary
-keep class com.cloudinary.** { *; }
-dontwarn com.cloudinary.**

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable

# Keep model classes (important for Firebase serialization)
-keep class com.fakebook.fakebook.models.** { *; }

# Prevent obfuscation of classes used by reflection
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Video Player
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**
