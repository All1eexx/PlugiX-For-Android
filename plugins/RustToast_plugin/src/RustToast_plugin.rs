use jni::{
    JNIEnv,
    objects::{JObject, JValue},
    sys::{jobject, JNIEnv as RawJNIEnv},
};

#[no_mangle]
pub extern "C" fn OnPluginCreate(env: *mut RawJNIEnv, context: jobject) {
    println!("[Rust] OnPluginCreate called");

    let mut env = unsafe { JNIEnv::from_raw(env).expect("Failed to get JNIEnv") };
    
    android_logger::init_once(
        android_logger::Config::default()
            .with_tag("RustToast_Plugin")
            .with_max_level(log::LevelFilter::Info)
    );

    log::info!("Initializing plugin...");

    unsafe {
        if let Err(e) = show_toast(&mut env, context) {
            println!("[Rust Error] {}", e);
            log::error!("Toast error: {}", e);
            let _ = env.throw_new(
                "java/lang/RuntimeException",
                format!("Plugin error: {}", e),
            );
        } else {
            println!("[Rust] Toast shown successfully");
        }
    }
}

unsafe fn show_toast(env: &mut JNIEnv, context: jobject) -> jni::errors::Result<()> {
    println!("[Rust] Preparing to show toast");
    let toast_class = env.find_class("android/widget/Toast")?;
    let text = env.new_string("Hello from Rust plugin!")?;

    println!("[Rust] Calling Toast.makeText()");
    let toast = env.call_static_method(
        toast_class,
        "makeText",
        "(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;",
        &[
            JValue::Object(&JObject::from_raw(context)),
            JValue::Object(&text.into()),
            JValue::Int(0)
        ],
    )?.l()?;

    println!("[Rust] Calling Toast.show()");
    env.call_method(toast, "show", "()V", &[])?;
    
    Ok(())
}

#[no_mangle]
pub extern "C" fn GetPluginVersion() -> *const u8 {
    println!("[Rust] GetPluginVersion called");
    b"1.0.0\0".as_ptr()
}