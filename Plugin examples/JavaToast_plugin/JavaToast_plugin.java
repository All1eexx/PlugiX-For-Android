package com.all1eexxx;

import android.widget.Toast;
import android.content.Context;

public class JavaToast_plugin {
  public static void OnPluginCreate(Context ctx) {
    Toast.makeText(ctx, "Hello from Java Toast Plugin!", Toast.LENGTH_LONG).show();
  }
}
