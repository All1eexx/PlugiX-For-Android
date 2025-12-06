#include "{{PLUGINNAME}}.hpp"
#include "{{PLUGINNAME}}.h"
#include <android/log.h>
#include <cmath>

#define TAG "{{PLUGINNAME}}"

int {{PLUGINNAME}}_add(int a, int b)
{
    int result = a + b;
    __android_log_print(ANDROID_LOG_DEBUG, TAG, "Add: %d + %d = %d", a, b, result);
    return result;
}

int {{PLUGINNAME}}_multiply(int a, int b)
{
    int result = a * b;
    __android_log_print(ANDROID_LOG_DEBUG, TAG, "Multiply: %d * %d = %d", a, b, result);
    return result;
}

double {{PLUGINNAME}}_power(double base, double exponent)
{
    double result = std::pow(base, exponent);
    __android_log_print(ANDROID_LOG_DEBUG, TAG, "Power: %.2f ^ %.2f = %.2f", base, exponent, result);
    return result;
}