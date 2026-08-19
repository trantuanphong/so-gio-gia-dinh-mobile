plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "phongtt.sogiogiadinh"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "phongtt.sogiogiadinh"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keyAliasParam = project.findProperty("KEY_ALIAS") as String? ?: System.getenv("KEY_ALIAS")
            val keyPasswordParam = project.findProperty("KEY_PASSWORD") as String? ?: System.getenv("KEY_PASSWORD")
            val storeFileParam = project.findProperty("STORE_FILE") as String? ?: System.getenv("STORE_FILE")
            val storePasswordParam = project.findProperty("STORE_PASSWORD") as String? ?: System.getenv("STORE_PASSWORD")

            if (storeFileParam != null) {
                val file = if (File(storeFileParam).isAbsolute) File(storeFileParam) else File(project.projectDir, storeFileParam)
                if (file.exists()) {
                    keyAlias = keyAliasParam
                    keyPassword = keyPasswordParam
                    storeFile = file
                    storePassword = storePasswordParam
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
