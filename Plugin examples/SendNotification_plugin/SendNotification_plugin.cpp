#include "SendNotification_plugin.hpp"
#include <jni.h>
#include <android/log.h>
#include <ctime>
#include <cstdio>

#define TAG "SendNotification_plugin"

extern "C" void OnPluginCreate(JNIEnv *env, jobject context)
{
  __android_log_print(ANDROID_LOG_INFO, TAG, "OnPluginCreate called");

  jclass contextClass = env->GetObjectClass(context);
  if (!contextClass)
  {
    __android_log_print(ANDROID_LOG_ERROR, TAG, "contextClass == null");
    return;
  }

  jmethodID getSystemService = env->GetMethodID(contextClass, "getSystemService", "(Ljava/lang/String;)Ljava/lang/Object;");
  if (!getSystemService)
  {
    __android_log_print(ANDROID_LOG_ERROR, TAG, "getSystemService method not found");
    env->DeleteLocalRef(contextClass);
    return;
  }

  jstring notificationServiceStr = env->NewStringUTF("notification");
  jobject notificationManager = env->CallObjectMethod(context, getSystemService, notificationServiceStr);
  env->DeleteLocalRef(notificationServiceStr);
  env->DeleteLocalRef(contextClass);

  if (!notificationManager)
  {
    __android_log_print(ANDROID_LOG_ERROR, TAG, "Failed to get NotificationManager");
    return;
  }

  jclass buildVersionClass = env->FindClass("android/os/Build$VERSION");
  jfieldID sdkIntField = env->GetStaticFieldID(buildVersionClass, "SDK_INT", "I");
  jint sdkInt = env->GetStaticIntField(buildVersionClass, sdkIntField);
  env->DeleteLocalRef(buildVersionClass);

  if (sdkInt >= 33)
  {
    jclass contextCompatClass = env->FindClass("androidx/core/content/ContextCompat");
    jmethodID checkSelfPermission = env->GetStaticMethodID(contextCompatClass, "checkSelfPermission", "(Landroid/content/Context;Ljava/lang/String;)I");

    jstring permissionStr = env->NewStringUTF("android.permission.POST_NOTIFICATIONS");
    jint permissionResult = env->CallStaticIntMethod(contextCompatClass, checkSelfPermission, context, permissionStr);
    env->DeleteLocalRef(permissionStr);
    env->DeleteLocalRef(contextCompatClass);

    if (permissionResult != 0)
    {
      __android_log_print(ANDROID_LOG_WARN, TAG, "No POST_NOTIFICATIONS permission");
      return;
    }
  }

  if (sdkInt >= 26)
  {
    jclass notificationChannelClass = env->FindClass("android/app/NotificationChannel");
    jmethodID channelCtor = env->GetMethodID(notificationChannelClass, "<init>", "(Ljava/lang/String;Ljava/lang/CharSequence;I)V");

    jstring channelId = env->NewStringUTF("plugin_channel_id");
    jstring channelName = env->NewStringUTF("Plugin Channel");
    jint importanceHigh = 4;

    jobject channel = env->NewObject(notificationChannelClass, channelCtor, channelId, channelName, importanceHigh);
    jclass notificationManagerClass = env->GetObjectClass(notificationManager);
    jmethodID createChannel = env->GetMethodID(notificationManagerClass, "createNotificationChannel", "(Landroid/app/NotificationChannel;)V");
    env->CallVoidMethod(notificationManager, createChannel, channel);

    env->DeleteLocalRef(channelId);
    env->DeleteLocalRef(channelName);
    env->DeleteLocalRef(channel);
    env->DeleteLocalRef(notificationChannelClass);
    env->DeleteLocalRef(notificationManagerClass);
  }

  jclass builderClass = env->FindClass("androidx/core/app/NotificationCompat$Builder");
  jmethodID builderCtor = env->GetMethodID(builderClass, "<init>", "(Landroid/content/Context;Ljava/lang/String;)V");

  jstring channelIdStr = env->NewStringUTF("plugin_channel_id");
  jobject builder = env->NewObject(builderClass, builderCtor, context, channelIdStr);
  env->DeleteLocalRef(channelIdStr);

  jmethodID setSmallIcon = env->GetMethodID(builderClass, "setSmallIcon", "(I)Landroidx/core/app/NotificationCompat$Builder;");
  env->CallObjectMethod(builder, setSmallIcon, 17301651);

  jmethodID setTitle = env->GetMethodID(builderClass, "setContentTitle", "(Ljava/lang/CharSequence;)Landroidx/core/app/NotificationCompat$Builder;");
  jstring title = env->NewStringUTF("Plugin message");
  env->CallObjectMethod(builder, setTitle, title);
  env->DeleteLocalRef(title);

  jmethodID setText = env->GetMethodID(builderClass, "setContentText", "(Ljava/lang/CharSequence;)Landroidx/core/app/NotificationCompat$Builder;");
  jstring text = env->NewStringUTF("This is a detailed message from the plugin");
  env->CallObjectMethod(builder, setText, text);
  env->DeleteLocalRef(text);

  jmethodID setProgress = env->GetMethodID(builderClass, "setProgress", "(IIZ)Landroidx/core/app/NotificationCompat$Builder;");
  env->CallObjectMethod(builder, setProgress, 100, 70, JNI_FALSE);

  jmethodID setPriority = env->GetMethodID(builderClass, "setPriority", "(I)Landroidx/core/app/NotificationCompat$Builder;");
  env->CallObjectMethod(builder, setPriority, 1);

  jmethodID setDefaults = env->GetMethodID(builderClass, "setDefaults", "(I)Landroidx/core/app/NotificationCompat$Builder;");
  env->CallObjectMethod(builder, setDefaults, 1);

  jmethodID setAutoCancel = env->GetMethodID(builderClass, "setAutoCancel", "(Z)Landroidx/core/app/NotificationCompat$Builder;");
  env->CallObjectMethod(builder, setAutoCancel, JNI_TRUE);

  jmethodID setWhen = env->GetMethodID(builderClass, "setWhen", "(J)Landroidx/core/app/NotificationCompat$Builder;");
  env->CallObjectMethod(builder, setWhen, (jlong)time(nullptr) * 1000);

  jlongArray pattern = env->NewLongArray(2);
  jlong pat[2] = {0, 400};
  env->SetLongArrayRegion(pattern, 0, 2, pat);
  jmethodID setVibrate = env->GetMethodID(builderClass, "setVibrate", "([J)Landroidx/core/app/NotificationCompat$Builder;");
  env->CallObjectMethod(builder, setVibrate, pattern);
  env->DeleteLocalRef(pattern);

  jclass inboxStyleClass = env->FindClass("androidx/core/app/NotificationCompat$InboxStyle");
  jmethodID inboxCtor = env->GetMethodID(inboxStyleClass, "<init>", "()V");
  jobject inboxStyle = env->NewObject(inboxStyleClass, inboxCtor);
  jmethodID addLine = env->GetMethodID(inboxStyleClass, "addLine", "(Ljava/lang/CharSequence;)Landroidx/core/app/NotificationCompat$InboxStyle;");

  for (int i = 0; i < 4; ++i)
  {
    char buffer[32];
    snprintf(buffer, sizeof(buffer), "Line %d", i + 1);
    jstring line = env->NewStringUTF(buffer);
    env->CallObjectMethod(inboxStyle, addLine, line);
    env->DeleteLocalRef(line);
  }

  jmethodID setStyle = env->GetMethodID(builderClass, "setStyle", "(Landroidx/core/app/NotificationCompat$Style;)Landroidx/core/app/NotificationCompat$Builder;");
  env->CallObjectMethod(builder, setStyle, inboxStyle);
  env->DeleteLocalRef(inboxStyle);
  env->DeleteLocalRef(inboxStyleClass);

  jmethodID addAction = env->GetMethodID(builderClass, "addAction", "(ILjava/lang/CharSequence;Landroid/app/PendingIntent;)Landroidx/core/app/NotificationCompat$Builder;");
  jstring btnText = env->NewStringUTF("Open");
  env->CallObjectMethod(builder, addAction, 17301504, btnText, static_cast<jobject>(nullptr));
  env->DeleteLocalRef(btnText);

  jmethodID buildMethod = env->GetMethodID(builderClass, "build", "()Landroid/app/Notification;");
  jobject notification = env->CallObjectMethod(builder, buildMethod);

  jclass notificationManagerClass = env->GetObjectClass(notificationManager);
  jmethodID notifyMethod = env->GetMethodID(notificationManagerClass, "notify", "(ILandroid/app/Notification;)V");
  env->CallVoidMethod(notificationManager, notifyMethod, 42, notification);

  env->DeleteLocalRef(notificationManagerClass);
  env->DeleteLocalRef(notificationManager);
  env->DeleteLocalRef(builder);
  env->DeleteLocalRef(builderClass);

  __android_log_print(ANDROID_LOG_INFO, TAG, "Notification sent successfully");
}
