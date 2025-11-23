plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.all1eexxx.plugix"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.all1eexxx.plugix"
        minSdk = 21
        targetSdk = 36
        versionCode = 121
        versionName = "1.2.2"


        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        

        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64")
        }

        androidResources {
            @Suppress("UnstableApiUsage")
            localeFilters.add("en")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            isDebuggable = false
            isJniDebuggable = false
            renderscriptOptimLevel = 5
        }
        getByName("debug") {
            isJniDebuggable = true
            renderscriptOptimLevel = 0
            isDebuggable = true
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_24
        targetCompatibility = JavaVersion.VERSION_24
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_24)
        }
    }

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "4.1.2"
        }
    }

    buildFeatures {
        viewBinding = true
    }
    buildToolsVersion = "36.1.0"
    ndkVersion = "29.0.14206865"
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)
    implementation(libs.androidx.constraintlayout)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
}