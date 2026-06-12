plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.zoli.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.zoli.app"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// Copie automatique de l'APK release dans E:\Lova\Application\android
tasks.whenTaskAdded {
    if (name == "assembleRelease") {
        doLast {
            val apkDir = File("${rootProject.projectDir}/../build/app/outputs/flutter-apk")
            val destDir = File("${rootProject.projectDir}")
            apkDir.listFiles { f -> f.name.endsWith(".apk") }?.forEach { apk ->
                apk.copyTo(File(destDir, apk.name), overwrite = true)
                println("✅ APK copié : ${destDir.absolutePath}/${apk.name}")
            }
        }
    }
}
