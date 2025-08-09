package com.all1eexxx

import android.util.Log
import android.content.Context

class PLUGINNAME {
    companion object {
      private const val TAG = "PLUGINNAME"
      @JvmStatic
      fun OnPluginCreate(ctx: Context) {
        Log.i(TAG, "Hello World from PLUGINNAME plugin!")
      }
    }
}