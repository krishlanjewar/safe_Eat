# Flutter Specific Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Supabase / HTTP preservation
-keep class com.google.gson.** { *; }
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# OpenFoodFacts & Mobile Scanner might need native preservation
-keep class net.sourceforge.zbar.** { *; }
-keep class com.google.zxing.** { *; }
