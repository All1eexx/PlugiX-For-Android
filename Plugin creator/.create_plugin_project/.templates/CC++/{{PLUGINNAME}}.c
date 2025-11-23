#include "{{PLUGINNAME}}.h"
#include "{{PLUGINNAME}}.hpp"
#include <android/log.h>

#define TAG "{{PLUGINNAME}}"

void OnPluginCreate(JNIEnv *env, jobject context)
{
    __android_log_print(ANDROID_LOG_INFO, TAG, "Hello World from {{PLUGINNAME}} plugin!");
    
    int sum = {{PLUGINNAME}}_add(5, 3);
    int product = {{PLUGINNAME}}_multiply(4, 7);
    double power_result = {{PLUGINNAME}}_power(2.0, 3.0);
    
    __android_log_print(ANDROID_LOG_INFO, TAG, 
                       "Math results: Sum=%d, Product=%d, Power=%.2f", 
                       sum, product, power_result);
}