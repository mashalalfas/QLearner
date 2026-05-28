# Keep notification icons from being stripped by R8 resource shrinker.
-keep class com.example.quranaudio.** { *; }
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**