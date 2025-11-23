#include "AlertDialog_plugin.h"
#include <android/log.h>

#define LOG_TAG "AlertDialog_Plugin"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

void ShowAlertDialog(JNIEnv *env, jobject context, const char *title, const char *message)
{
  jclass activityClass = (*env)->GetObjectClass(env, context);
  if (!activityClass)
  {
    LOGE("Failed to get Activity class");
    return;
  }

  jclass builderClass = (*env)->FindClass(env, "android/app/AlertDialog$Builder");
  if (!builderClass)
  {
    LOGE("Failed to find AlertDialog.Builder class.");
    (*env)->DeleteLocalRef(env, activityClass);
    return;
  }

  jmethodID builderCtor = (*env)->GetMethodID(env, builderClass, "<init>", "(Landroid/content/Context;)V");
  jobject builder = (*env)->NewObject(env, builderClass, builderCtor, context);

  jstring jTitle = (*env)->NewStringUTF(env, title);
  jstring jMessage = (*env)->NewStringUTF(env, message);

  jmethodID setTitle = (*env)->GetMethodID(env, builderClass, "setTitle", "(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;");
  jmethodID setMessage = (*env)->GetMethodID(env, builderClass, "setMessage", "(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;");

  (*env)->CallObjectMethod(env, builder, setTitle, jTitle);
  (*env)->CallObjectMethod(env, builder, setMessage, jMessage);

  jstring ok1Text = (*env)->NewStringUTF(env, "OK1");
  jmethodID setNeutralButton = (*env)->GetMethodID(
      env,
      builderClass,
      "setNeutralButton",
      "(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;");
  (*env)->CallObjectMethod(env, builder, setNeutralButton, ok1Text, NULL);

  jstring ok2Text = (*env)->NewStringUTF(env, "OK2");
  jmethodID setNegativeButton = (*env)->GetMethodID(
      env,
      builderClass,
      "setNegativeButton",
      "(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;");
  (*env)->CallObjectMethod(env, builder, setNegativeButton, ok2Text, NULL);

  jstring ok3Text = (*env)->NewStringUTF(env, "OK3");
  jmethodID setPositiveButton = (*env)->GetMethodID(
      env,
      builderClass,
      "setPositiveButton",
      "(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;");
  (*env)->CallObjectMethod(env, builder, setPositiveButton, ok3Text, NULL);

  jmethodID createMethod = (*env)->GetMethodID(env, builderClass, "create", "()Landroid/app/AlertDialog;");
  jobject dialog = (*env)->CallObjectMethod(env, builder, createMethod);

  jclass dialogClass = (*env)->GetObjectClass(env, dialog);
  jmethodID showMethod = (*env)->GetMethodID(env, dialogClass, "show", "()V");
  (*env)->CallVoidMethod(env, dialog, showMethod);

  (*env)->DeleteLocalRef(env, jTitle);
  (*env)->DeleteLocalRef(env, jMessage);
  (*env)->DeleteLocalRef(env, ok1Text);
  (*env)->DeleteLocalRef(env, ok2Text);
  (*env)->DeleteLocalRef(env, ok3Text);
  (*env)->DeleteLocalRef(env, builder);
  (*env)->DeleteLocalRef(env, dialog);
  (*env)->DeleteLocalRef(env, builderClass);
  (*env)->DeleteLocalRef(env, activityClass);
}

void OnPluginCreate(JNIEnv *env, jobject context)
{
  LOGI("AlertDialog from C plugin");
  ShowAlertDialog(env, context, "Hello from C", "This dialog is called from AlertDialog plugin, C code, not C++!");
}