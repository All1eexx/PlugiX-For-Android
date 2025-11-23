#ifndef SENDNOTIFICATION_PLUGIN_HPP
#define SENDNOTIFICATION_PLUGIN_HPP

#include <jni.h>

extern "C"
{
  void OnPluginCreate(JNIEnv *env, jobject context);
}

#endif
