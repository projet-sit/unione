import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Signature release : lue depuis android/key.properties (jamais commité).
// Sans ce fichier, le build release retombe sur la signature debug.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
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

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Signature production si key.properties présent, debug sinon.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
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
