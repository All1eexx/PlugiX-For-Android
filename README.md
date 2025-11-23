<div style="text-align: center;">

# 🧩 PlugiX 🧩

![Android Plugin System](https://img.shields.io/badge/Android_Plugin_Loader-3ddc84?style=for-the-badge&logo=android&logoColor=white&color=121212&labelColor=3ddc84)

</div>

<p style="text-align: center;">
  <a href="#"><img alt="License" src="https://img.shields.io/badge/LICENSE-MIT-blueviolet?style=flat-square&logo=opensourceinitiative&labelColor=282c34"></a>
  <a href="#"><img alt="Platform" src="https://img.shields.io/badge/Platform-Android-3ddc84?style=flat-square&logo=android&logoColor=white&labelColor=282c34"></a>
  <a href="#"><img alt="Min API" src="https://img.shields.io/badge/API-21+-00B0FF?style=flat-square&logo=android-studio&logoColor=white&labelColor=282c34"></a>
</p>

<p style="text-align: center;">
  <a href="#"><img alt="Release" src="https://img.shields.io/github/v/release/All1eexx/PlugiX-For-Android?include_prereleases&style=flat-square&color=FF6D00&logo=github&logoColor=white&labelColor=282c34"></a>
  <a href="#"><img alt="Downloads" src="https://img.shields.io/github/downloads/All1eexx/PlugiX-For-Android/total?style=flat-square&color=4CAF50&logo=download&labelColor=282c34"></a>
  <a href="#"><img alt="Last commit" src="https://img.shields.io/github/last-commit/All1eexx/PlugiX-For-Android?style=flat-square&color=slateblue&logo=git&labelColor=282c34"></a>
  <a href="#"><img alt="Stars" src="https://img.shields.io/github/stars/All1eexx/PlugiX-For-Android?style=flat-square&color=FFD700&logo=star&labelColor=282c34"></a>
  <a href="#"><img alt="Forks" src="https://img.shields.io/github/forks/All1eexx/PlugiX-For-Android?style=flat-square&color=29B6F6&logo=code-fork&labelColor=282c34"></a>

</p>

---

## 📦 Features
- **Multi-language plugin support**:
    - 🔌 Native: `.so` (C/C++) via `dlopen`
    - ☕️ Java/Kotlin: `.dex` via `DexClassLoader`
- 🚀 Unified entry points:
    - `OnPluginCreate(JNIEnv*, jobject)` for native plugins
    - `OnPluginCreate(Context)` for Java/Kotlin plugins
- 🖼️ UI integration:
    - Android views from C++ via JNI
    - Direct XML inflation from Java/Kotlin
- 🔄 Dynamic updates:
    - No recompilation needed
    - Hot-plugging from external storage

---

## ⚙️ Plugin Architecture
### For Native (.so) Plugins
1. The app searches for .so files in:
storage/emulated/0/Android/data/com.all1eexxx.plugix/files/plugins
and copies them to internal storage.
2. Loads them via dlopen
3. Looks for the OnPluginCreate symbol
4. Calls it with JNIEnv* and Activity context
### For Java/Kotlin (.dex) Plugins
1. The app searches for .dex files in:
   storage/emulated/0/Android/data/com.all1eexxx.plugix/files/plugins
   and copies them to internal storage (for example, to codeCacheDir/plugins).
2. For each .dex file, a DexClassLoader is created, specifying the path to the file, an optimized directory for the output, and the parent class loader.
3. Using DexFile or the DexClassLoader, the app enumerates all classes inside the .dex file.
4. For each class, it looks for a static method with the signature:
OnPluginCreate(Context ctx).
5. If such a method is found, it is invoked with the current Android context.

---

## ⚙️ Architecture

```txt
📁 storage/emulated/0/Android/data/com.all1eexxx.plugix/files/plugins
   ├── native_module.so    # C/C++ plugin
   ├── java_plugin.dex     # Java compiled plugin
   ├── kt_plugin.dex       # Kotlin compiled plugin
   └── ...
   ```

✅ Native Plugin must export:
```cpp
extern "C" void OnPluginCreate(JNIEnv* env, jobject activity);
```
✅ Java/Kotlin Plugin must define:
```Java
public static void OnPluginCreate(Context ctx) {}
```
---

## 🔌 Sample Plugins

| Type             | Plugin                                                                                                                                                   | Description                           | Version |
|------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------|---------|
| **Native(C++)**  | [CPPToast_plugin](https://github.com/All1eexx/PlugiX-For-Android/tree/1.0.0/Plugin%20examples/CPPToast_plugin)                                           | Displays Toast from C++               | 1.0.0   |
| **Native(C++)**  | [GUI_plugin](https://github.com/All1eexx/PlugiX-For-Android/tree/1.0.0/Plugin%20examples/GUI_plugin)                                                     | Creates UI elements (TextView/Button) | 1.0.0   |
| **Native(C++)**  | [Resource_plugin](https://github.com/All1eexx/PlugiX-For-Android/tree/1.1.0/Plugin%20examples/Resource_plugin)                                           | File type support                     | 1.1.0   |
| **Native(C++)**  | [RequestNotificationPermission_plugin](https://github.com/All1eexx/PlugiX-For-Android/tree/1.1.2/Plugin%20examples/RequestNotificationPermission_plugin) | Handles runtime permissions           | 1.1.2   |
| **Native(C++)**  | [SendNotification_plugin](https://github.com/All1eexx/PlugiX-For-Android/tree/1.1.3/Plugin%20examples/SendNotification_plugin)                           | System notifications                  | 1.1.3   |
| **Native(C)**    | [AlertDialog_plugin](https://github.com/All1eexx/PlugiX-For-Android/tree/1.2.0/Plugin%20examples/AlertDialog_plugin)                                     | Shows native AlertDialog              | 1.2.0   |
| **Java**         | [JavaToast_plugin](https://github.com/All1eexx/PlugiX-For-Android/tree/1.2.0/Plugin%20examples/JavaToast_plugin)                                         | Toast notifications in Java           | 1.2.0   |
| **Kotlin**       | [KotlinToast_plugin](https://github.com/All1eexx/PlugiX-For-Android/tree/1.2.1/Plugin%20examples/KotlinToast_plugin)                                     | Toast notifications in Kotlin         | 1.2.1   |
| **Kotlin**       | [KotlinCoroutines_plugin](https://github.com/All1eexx/PlugiX-For-Android/tree/1.2.2/Plugin%20examples/KotlinCoroutines_plugin)                           | Kotlin Coroutines in plugin           | 1.2.2   |
| **Native(Rust)** | [RustToast_plugin](https://github.com/All1eexx/PlugiX-For-Android/tree/1.2.2/Plugin%20examples/RustToast_plugin)                                         | Displays Toast from Rust              | 1.2.2   |
---

## 🔧 Technical Notes
1. Entry Points:
   - Native: Must export OnPluginCreate with JNI params
   - Java/Kotlin: Static method with Context parameter
2. UI Limitations:
   - Native: Event handling requires JNI callbacks
   -  Java/Kotlin: Full Android UI capabilities
3. Security:
   - Plugins execute in host app's context

## 📄 License
MIT License. Use, explore, contribute.

<div style="text-align: center; margin-top: 2rem;"> ⭐ Found this useful? Star the repo to support development! </div> 