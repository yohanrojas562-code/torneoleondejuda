import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Carga la configuracion del keystore release desde android/key.properties.
// Ese archivo NO esta en git (ver .gitignore) — el dev/equipo debe crearlo
// localmente con las credenciales del upload key de Play Store. Si no existe
// (ej. en CI sin secrets), `flutter build apk --release` cae al debug-sign
// que sirve para sideload pero NO para Play Store.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.torneoleondejuda.torneo_leon_de_juda"
    compileSdk = flutter.compileSdkVersion
    // Forzado a 27.0.12077973 — varios plugins (mobile_scanner, file_picker,
    // flutter_secure_storage, etc.) requieren minimo 27.x. NDK es backward
    // compatible asi que tomar el mayor evita el warning de Gradle.
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.torneoleondejuda.torneo_leon_de_juda"
        // minSdk 21 (Android 5.0) cubre 99%+ devices y es requisito de
        // mobile_scanner. targetSdk 35 = Android 15 (latest).
        minSdk = 21
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            // Si existe key.properties, firma con upload key real (Play
            // Store). Sino cae al debug-sign para que el build siga funcionando
            // localmente sin las credenciales.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
