#ifndef {{PLUGINNAME}}_H
#define {{PLUGINNAME}}_H

#include <jni.h>

#ifdef __cplusplus
extern "C"
{
#endif

void OnPluginCreate(JNIEnv *env, jobject context);

#ifdef __cplusplus
}
#endif

#endif