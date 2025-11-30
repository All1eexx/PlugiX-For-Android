package {{PACKAGENAME}};

import android.util.Log;
import android.content.Context;

public class {{PLUGINNAME}} {
  private static final String TAG = "{{PLUGINNAME}}";

  public static void OnPluginCreate(Context ctx) {
    Log.i(TAG, "Hello World from {{PLUGINNAME}} plugin!");
  }
}
