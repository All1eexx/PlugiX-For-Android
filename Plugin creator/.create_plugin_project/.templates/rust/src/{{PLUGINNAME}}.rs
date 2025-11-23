use android_logger::{Config, FilterBuilder};
use jni::{JNIEnv, objects::JObject};
use log::{info, LevelFilter};

const TAG: &str = "PLUGINNAME";

#[no_mangle]
pub extern "C" fn Java_OnPluginCreate(env: JNIEnv, context: JObject) {
    android_logger::init_once(
        Config::default()
            .with_tag(TAG)
            .with_filter(
                FilterBuilder::new()
                    .filter_level(LevelFilter::Info)
                    .build(),
    );
    
    info!("Hello World from PLUGINNAME plugin!");
}