#include "PLUGINNAME.hpp"
#include <jni.h>
#include <android/log.h>

#define TAG "PLUGINNAME"

extern "C" void OnPluginCreate(JNIEnv *env, jobject context)
{
    __android_log_print(ANDROID_LOG_INFO, TAG, "Hello World from PLUGINNAME plugin!");
}
