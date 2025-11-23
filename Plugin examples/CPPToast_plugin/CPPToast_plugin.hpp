#ifndef CPPTOAST_PLUGIN_HPP
#define CPPTOAST_PLUGIN_HPP

#include <jni.h>

extern "C"
{
  void OnPluginCreate(JNIEnv *env, jobject context);
}

#endif
