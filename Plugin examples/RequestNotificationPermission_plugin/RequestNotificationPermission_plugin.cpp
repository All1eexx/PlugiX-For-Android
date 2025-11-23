#include "RequestNotificationPermission_plugin.hpp"
#include <jni.h>
#include <android/log.h>

#define TAG "RequestNotificationPermission_plugin"

static constexpr int REQUEST_CODE = 69;

static void logException(JNIEnv *env)
{
    if (env->ExceptionCheck())
    {
        __android_log_print(ANDROID_LOG_ERROR, TAG, "JNI Exception detected");
        env->ExceptionDescribe();
        env->ExceptionClear();
        __android_log_print(ANDROID_LOG_ERROR, TAG, "JNI Exception cleared");
    }
}

extern "C" void OnPluginCreate(JNIEnv *env, jobject context)
{
    __android_log_print(ANDROID_LOG_INFO, TAG, "OnPluginCreate called");

    jclass contextClass = env->GetObjectClass(context);
    if (!contextClass)
    {
        __android_log_print(ANDROID_LOG_ERROR, TAG, "Failed to get context class");
        logException(env);
        return;
    }
    __android_log_print(ANDROID_LOG_DEBUG, TAG, "Context class obtained");

    jclass buildVersionClass = env->FindClass("android/os/Build$VERSION");
    if (!buildVersionClass)
    {
        __android_log_print(ANDROID_LOG_ERROR, TAG, "Failed to find Build$VERSION class");
        logException(env);
        return;
    }
    __android_log_print(ANDROID_LOG_DEBUG, TAG, "Build$VERSION class found");

    jfieldID sdkIntField = env->GetStaticFieldID(buildVersionClass, "SDK_INT", "I");
    if (!sdkIntField)
    {
        __android_log_print(ANDROID_LOG_ERROR, TAG, "Failed to get SDK_INT field ID");
        logException(env);
        return;
    }
    __android_log_print(ANDROID_LOG_DEBUG, TAG, "SDK_INT field ID retrieved");

    jint sdkInt = env->GetStaticIntField(buildVersionClass, sdkIntField);
    __android_log_print(ANDROID_LOG_INFO, TAG, "Android SDK_INT = %d", sdkInt);

    if (sdkInt < 33)
    {
        __android_log_print(ANDROID_LOG_INFO, TAG, "SDK < 33, notification permission not required");
        return;
    }

    jclass contextCompatClass = env->FindClass("androidx/core/content/ContextCompat");
    if (!contextCompatClass)
    {
        __android_log_print(ANDROID_LOG_ERROR, TAG, "Failed to find ContextCompat class");
        logException(env);
        return;
    }
    __android_log_print(ANDROID_LOG_DEBUG, TAG, "ContextCompat class found");

    jmethodID checkSelfPermissionMethod = env->GetStaticMethodID(
        contextCompatClass,
        "checkSelfPermission",
        "(Landroid/content/Context;Ljava/lang/String;)I");
    if (!checkSelfPermissionMethod)
    {
        __android_log_print(ANDROID_LOG_ERROR, TAG, "Failed to find checkSelfPermission method");
        logException(env);
        return;
    }
    __android_log_print(ANDROID_LOG_DEBUG, TAG, "checkSelfPermission method ID retrieved");

    jstring permissionString = env->NewStringUTF("android.permission.POST_NOTIFICATIONS");
    jint permissionCheck = env->CallStaticIntMethod(contextCompatClass, checkSelfPermissionMethod, context, permissionString);
    logException(env);
    __android_log_print(ANDROID_LOG_INFO, TAG, "Permission check result = %d", permissionCheck);

    if (permissionCheck == 0)
    {
        __android_log_print(ANDROID_LOG_INFO, TAG, "Permission POST_NOTIFICATIONS already granted");
        env->DeleteLocalRef(permissionString);
        return;
    }
    else
    {
        __android_log_print(ANDROID_LOG_INFO, TAG, "Permission POST_NOTIFICATIONS NOT granted, requesting permission");
    }

    env->DeleteLocalRef(permissionString);

    jmethodID requestPermissionsMethod = env->GetMethodID(contextClass, "requestPermissions", "([Ljava/lang/String;I)V");
    if (!requestPermissionsMethod)
    {
        __android_log_print(ANDROID_LOG_ERROR, TAG, "Failed to find requestPermissions method in Activity");
        logException(env);
        return;
    }
    __android_log_print(ANDROID_LOG_DEBUG, TAG, "requestPermissions method ID retrieved");

    jclass stringClass = env->FindClass("java/lang/String");
    if (!stringClass)
    {
        __android_log_print(ANDROID_LOG_ERROR, TAG, "Failed to find java/lang/String class");
        logException(env);
        return;
    }
    __android_log_print(ANDROID_LOG_DEBUG, TAG, "java/lang/String class found");

    jobjectArray permissionsArray = env->NewObjectArray(1, stringClass, nullptr);
    if (!permissionsArray)
    {
        __android_log_print(ANDROID_LOG_ERROR, TAG, "Failed to create permissions array");
        return;
    }
    __android_log_print(ANDROID_LOG_DEBUG, TAG, "Permissions array created");

    jstring permissionRequest = env->NewStringUTF("android.permission.POST_NOTIFICATIONS");
    env->SetObjectArrayElement(permissionsArray, 0, permissionRequest);

    env->CallVoidMethod(context, requestPermissionsMethod, permissionsArray, REQUEST_CODE);
    logException(env);

    env->DeleteLocalRef(permissionRequest);
    env->DeleteLocalRef(permissionsArray);

    __android_log_print(ANDROID_LOG_INFO, TAG, "Permission request sent with requestCode=%d", REQUEST_CODE);
}
