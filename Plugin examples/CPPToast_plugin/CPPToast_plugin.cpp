#include "CPPToast_plugin.hpp"
#include <jni.h>
#include <android/log.h>

#define TAG "CPPToast_plugin"

extern "C" void OnPluginCreate(JNIEnv *env, jobject context)
{
    __android_log_print(ANDROID_LOG_INFO, TAG, "OnPluginCreate called");

    jclass toastClass = env->FindClass("android/widget/Toast");
    if (!toastClass)
    {
        __android_log_print(ANDROID_LOG_ERROR, TAG, "Toast class not found");
        return;
    }

    jmethodID makeText = env->GetStaticMethodID(toastClass, "makeText",
                                                "(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;");
    if (!makeText)
    {
        __android_log_print(ANDROID_LOG_ERROR, TAG, "Method makeText not found");
        return;
    }

    jstring text = env->NewStringUTF("Hello from С++ Toast Plugin!");
    jobject toast = env->CallStaticObjectMethod(toastClass, makeText, context, text, 0);

    jmethodID show = env->GetMethodID(toastClass, "show", "()V");
    if (show && toast)
    {
        env->CallVoidMethod(toast, show);
        __android_log_print(ANDROID_LOG_INFO, TAG, "Toast showed");
    }
    else
    {
        __android_log_print(ANDROID_LOG_ERROR, TAG, "Toast failed to display");
    }
}
