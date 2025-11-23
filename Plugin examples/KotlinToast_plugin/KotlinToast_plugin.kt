package com.all1eexxx

import android.content.Context
import kotlin.jvm.JvmStatic
import android.widget.Toast

class KotlinToast_plugin {
    companion object {
        @JvmStatic
        fun OnPluginCreate(ctx: Context) {
            Toast.makeText(ctx, "Hello from Kotlin Toast Plugin!", Toast.LENGTH_LONG).show()
        }
    }
}
