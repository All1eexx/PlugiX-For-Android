#ifndef PLUGINNAME_H  
#define PLUGINNAME_H  

#include <jni.h>  

#ifdef __cplusplus  
extern "C" {  
#endif  

void OnPluginCreate(JNIEnv *env, jobject context);  

#ifdef __cplusplus  
}  
#endif  

#endif // PLUGINNAME_H  