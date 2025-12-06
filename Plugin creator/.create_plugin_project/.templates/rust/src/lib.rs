use android_logger::Config;
use log::{info, LevelFilter};

const TAG: &str = "{{PLUGINNAME}}";

#[no_mangle]
pub extern "C" fn OnPluginCreate(env: jni::JNIEnv, _context: jni::objects::JObject) {
    android_logger::init_once(
        Config::default()
            .with_max_level(LevelFilter::Debug)
            .with_tag(TAG),
    );

    info!("Hello World from Rust {{PLUGINNAME}} plugin!");
}
