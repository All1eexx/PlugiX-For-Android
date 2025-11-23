#include "GUI_plugin.hpp"
#include <jni.h>
#include <android/log.h>

#define TAG "GUI_Plugin"

extern "C" void OnPluginCreate(JNIEnv *env, jobject context)
{
  __android_log_print(ANDROID_LOG_INFO, "GUI_Plugin", "OnPluginCreate: creating UI via JNI");

  jclass activityClass = env->GetObjectClass(context);
  jmethodID findViewById = env->GetMethodID(activityClass, "findViewById", "(I)Landroid/view/View;");
  jint android_R_id_content = 0x01020002;
  jobject rootView = env->CallObjectMethod(context, findViewById, android_R_id_content);

  jclass linearLayoutClass = env->FindClass("android/widget/LinearLayout");
  jmethodID linearLayoutCtor = env->GetMethodID(linearLayoutClass, "<init>", "(Landroid/content/Context;)V");
  jobject linearLayout = env->NewObject(linearLayoutClass, linearLayoutCtor, context);

  jmethodID setOrientation = env->GetMethodID(linearLayoutClass, "setOrientation", "(I)V");
  env->CallVoidMethod(linearLayout, setOrientation, 1);

  jmethodID setGravity = env->GetMethodID(linearLayoutClass, "setGravity", "(I)V");
  env->CallVoidMethod(linearLayout, setGravity, 1);

  jmethodID setPadding = env->GetMethodID(linearLayoutClass, "setPadding", "(IIII)V");
  env->CallVoidMethod(linearLayout, setPadding, 0, 200, 0, 0);

  jclass layoutParamsClass = env->FindClass("android/widget/LinearLayout$LayoutParams");
  jmethodID layoutParamsCtor = env->GetMethodID(layoutParamsClass, "<init>", "(II)V");

  jint MATCH_PARENT = -1;
  jint WRAP_CONTENT = -2;

  jobject layoutParamsForRoot = env->NewObject(layoutParamsClass, layoutParamsCtor, MATCH_PARENT, MATCH_PARENT);
  jmethodID setLayoutParamsRoot = env->GetMethodID(linearLayoutClass, "setLayoutParams", "(Landroid/view/ViewGroup$LayoutParams;)V");
  env->CallVoidMethod(linearLayout, setLayoutParamsRoot, layoutParamsForRoot);

  jobject childLayoutParams = env->NewObject(layoutParamsClass, layoutParamsCtor, WRAP_CONTENT, WRAP_CONTENT);

  jclass textViewClass = env->FindClass("android/widget/TextView");
  jmethodID textViewCtor = env->GetMethodID(textViewClass, "<init>", "(Landroid/content/Context;)V");
  jobject textView = env->NewObject(textViewClass, textViewCtor, context);

  jmethodID setText = env->GetMethodID(textViewClass, "setText", "(Ljava/lang/CharSequence;)V");
  jstring text = env->NewStringUTF("Hello from GUI plugin!");
  env->CallVoidMethod(textView, setText, text);

  jmethodID setLayoutParams = env->GetMethodID(textViewClass, "setLayoutParams", "(Landroid/view/ViewGroup$LayoutParams;)V");
  env->CallVoidMethod(textView, setLayoutParams, childLayoutParams);

  jclass buttonClass = env->FindClass("android/widget/Button");
  jmethodID buttonCtor = env->GetMethodID(buttonClass, "<init>", "(Landroid/content/Context;)V");
  jobject button = env->NewObject(buttonClass, buttonCtor, context);

  jstring btnText = env->NewStringUTF("Click me");
  env->CallVoidMethod(button, setText, btnText);
  env->CallVoidMethod(button, setLayoutParams, childLayoutParams);

  jclass viewGroupClass = env->FindClass("android/view/ViewGroup");
  jmethodID addView = env->GetMethodID(viewGroupClass, "addView", "(Landroid/view/View;)V");
  env->CallVoidMethod(linearLayout, addView, textView);
  env->CallVoidMethod(linearLayout, addView, button);

  env->CallVoidMethod(rootView, addView, linearLayout);

  __android_log_print(ANDROID_LOG_INFO, "GUI_Plugin", "UI with layout and centering successfully added");
}
