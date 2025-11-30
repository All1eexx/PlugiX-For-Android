val PLUGIN_NAME: String = "{{PLUGINNAME}}"
val PLUGIN_VERSION: String = "1.0.0"
val MIN_SDK_VERSION: Int = {{MIN_SDK}}
val COMPILE_SDK_VERSION: Int = {{COMPILE_SDK}}
val JAVA_VERSION_NUMBER: String = "{{JAVA_VERSION}}"

val JAVA_PATH: String = "{{JAVA_HOME}}"
val ANDROID_SDK_PATH: String = "{{ANDROID_SDK}}"
val BUILD_TOOLS_VERSION: String = "{{BUILD_TOOLS_VERSION}}"

val ENABLE_OBFUSCATION: Boolean = false
val OBFUSCATION_TOOL: String = "R8" // Choose between "R8" or "PROGUARD"

plugins {
    id("java-library")
}

dependencies {
    if (ENABLE_OBFUSCATION && OBFUSCATION_TOOL.equals("R8", ignoreCase = true)) {
        runtimeOnly("com.android.tools:r8:8.13.17") // needed only for R8
    }
    
}










java {
    val javaVersion = JavaVersion.toVersion(JAVA_VERSION_NUMBER)
    sourceCompatibility = javaVersion
    targetCompatibility = javaVersion
}

repositories {
    gradlePluginPortal()
    google()
    mavenCentral()
    if (ENABLE_OBFUSCATION && OBFUSCATION_TOOL.equals("R8", ignoreCase = true)) {
        maven {
                url = uri("https://storage.googleapis.com/r8-releases/raw") // needed only for R8
        }
    }    
    
}

tasks.jar {
    archiveBaseName.set(PLUGIN_NAME)
    archiveVersion.set(PLUGIN_VERSION)
}

val D8_BAT_PATH: String = "$ANDROID_SDK_PATH/build-tools/$BUILD_TOOLS_VERSION/d8.bat"
val D8_JAR_PATH: String = "$ANDROID_SDK_PATH/build-tools/$BUILD_TOOLS_VERSION/lib/d8.jar"
val ANDROID_JAR_PATH: String = "$ANDROID_SDK_PATH/platforms/android-$COMPILE_SDK_VERSION/android.jar"
val JAVA_EXEC_PATH: String = "$JAVA_PATH/bin/java.exe"
val JAVAC_EXEC_PATH: String = "$JAVA_PATH/bin/javac.exe"
val PROGUARD_JAR_PATH: String = "$ANDROID_SDK_PATH/tools/proguard/lib/proguard.jar"
val PROGUARD_CONFIG_FILE: String = "proguard-rules.pro"

fun File.ensureExists(toolName: String) {
    if (!exists()) throw GradleException("$toolName not found: $absolutePath")
}

tasks.register("cleanObfuscationFiles") {
    group = "build"
    description = "Clean up all obfuscation temporary files"
    
    doLast {
        val buildDir = layout.buildDirectory.get().asFile
        val directoriesToClean = listOf(
            File(buildDir, "outputs/r8"),
            File(buildDir, "outputs/proguard"),
            File(project.rootDir, "output")
        )
        
        val filesToDelete = listOf("seeds.txt", "mapping.txt", "configuration.txt", "usage.txt", "null.txt")
        
        val allFilesToClean = directoriesToClean.flatMap { dir ->
            filesToDelete.map { fileName -> File(dir, fileName) }
        } + filesToDelete.map { File(project.rootDir, it) }
        
        allFilesToClean.forEach { file ->
            if (file.exists()) {
                file.delete()
                println("Cleaned: ${file.name}")
            }
        }
        
        println("Cleanup completed: all temporary files removed")
    }
}

fun validateBuildEnvironment() {
    val d8Exists = File(D8_BAT_PATH).exists() || File(D8_JAR_PATH).exists()
    if (!d8Exists) throw GradleException("D8 tool not found")
    
    File(ANDROID_JAR_PATH).ensureExists("Android Platform")
    File(JAVA_EXEC_PATH).ensureExists("Java")
    File(JAVAC_EXEC_PATH).ensureExists("Javac")
    
    if (ENABLE_OBFUSCATION && OBFUSCATION_TOOL.equals("PROGUARD", ignoreCase = true)) {
        File(PROGUARD_JAR_PATH).ensureExists("ProGuard")
        File(PROGUARD_CONFIG_FILE).ensureExists("ProGuard config")
    }
}

tasks.register<Exec>("buildDex") {
    group = "build"
    description = "Build DEX from JAR with optional obfuscation"
    
    if (ENABLE_OBFUSCATION) {
        dependsOn("buildDexFromObfuscatedJar")
    } else {
        dependsOn("buildDexFromJar")
    }
}

tasks.register<Exec>("buildDexFromJar") {
    group = "build"
    description = "Build DEX directly from JAR without obfuscation"
    dependsOn("jar")
    
    val jarFile = tasks.jar.get().archiveFile.get().asFile
    val dexDir = File(layout.buildDirectory.get().asFile, "outputs/dex")
    
    doFirst {
        dexDir.mkdirs()
        validateBuildEnvironment()
        jarFile.ensureExists("Input JAR")
        println("Building DEX from: ${jarFile.name}")
    }
    
    workingDir = project.rootDir
    
    val d8Command = if (File(D8_BAT_PATH).exists()) {
        listOf(
            D8_BAT_PATH,
            "--release",
            "--min-api", MIN_SDK_VERSION.toString(),
            "--lib", ANDROID_JAR_PATH,
            "--output", dexDir.absolutePath,
            jarFile.absolutePath
        )
    } else {
        listOf(
            JAVA_EXEC_PATH, "-jar", D8_JAR_PATH,
            "--release",
            "--min-api", MIN_SDK_VERSION.toString(),
            "--lib", ANDROID_JAR_PATH,
            "--output", dexDir.absolutePath,
            jarFile.absolutePath
        )
    }
    
    commandLine = d8Command
    
    doLast {
        validateDexOutput(dexDir)
    }
}

tasks.register<JavaExec>("r8") {
    group = "obfuscation"
    description = "Obfuscate using R8"
    dependsOn("jar")

    val jarFile = tasks.jar.get().archiveFile.get().asFile
    val r8Dir = File(layout.buildDirectory.get().asFile, "outputs/r8")
    val obfuscatedJar = File(r8Dir, "${PLUGIN_NAME}-obfuscated.jar")

    doFirst {
        r8Dir.mkdirs()
        File(PROGUARD_CONFIG_FILE).ensureExists("ProGuard config")
        println("R8 obfuscation started for: ${jarFile.name}")
    }

    classpath = configurations.runtimeClasspath.get().filter { it.name.startsWith("r8") }
    mainClass.set("com.android.tools.r8.R8")

    args = listOf(
        "--release",
        "--min-api", MIN_SDK_VERSION.toString(),
        "--lib", ANDROID_JAR_PATH,
        "--output", obfuscatedJar.absolutePath,
        "--pg-conf", PROGUARD_CONFIG_FILE,
        jarFile.absolutePath
    )

    doLast {
        if (obfuscatedJar.exists()) {
            println("✓ R8 obfuscation successful: ${obfuscatedJar.name}")
        } else {
            throw GradleException("R8 obfuscation failed - output JAR not created")
        }
    }
}

tasks.register<JavaExec>("proguard") {
    group = "obfuscation"
    description = "Obfuscate using ProGuard"
    dependsOn("jar")
    
    val jarFile = tasks.jar.get().archiveFile.get().asFile
    val proguardDir = File(layout.buildDirectory.get().asFile, "outputs/proguard")
    val obfuscatedJar = File(proguardDir, "${PLUGIN_NAME}-obfuscated.jar")
    
    val nullOutput = if (System.getProperty("os.name").lowercase().contains("windows")) {
        val nullFile = File(proguardDir, "null.txt").apply { writeText("") }
        nullFile.absolutePath
    } else {
        "/dev/null"
    }
    
    doFirst {
        proguardDir.mkdirs()
        File(PROGUARD_JAR_PATH).ensureExists("ProGuard")
        File(PROGUARD_CONFIG_FILE).ensureExists("ProGuard config")
        
        println("ProGuard obfuscation started for: ${jarFile.name}")
        println("Input JAR: ${jarFile.length()} bytes")
    }
    
    classpath = files(PROGUARD_JAR_PATH)
    mainClass.set("proguard.ProGuard")
    
    args = listOf(
        "-injars", jarFile.absolutePath,
        "-outjars", obfuscatedJar.absolutePath,
        "-libraryjars", ANDROID_JAR_PATH,
        "-include", PROGUARD_CONFIG_FILE,
        "-dontwarn",
        "-verbose",
        "-forceprocessing",
        "-optimizationpasses", "20",
        "-overloadaggressively",
        "-printseeds", nullOutput,
        "-printmapping", nullOutput,
        "-printconfiguration", nullOutput,
        "-printusage", nullOutput
    )
    
    doLast {
        if (obfuscatedJar.exists()) {
            println("✓ ProGuard obfuscation successful: ${obfuscatedJar.name}")
            println("Output JAR: ${obfuscatedJar.length()} bytes")
        } else {
            throw GradleException("ProGuard obfuscation failed - output JAR not created")
        }
    }
}

tasks.register("obfuscate") {
    group = "obfuscation"
    description = "Obfuscate JAR using configured tool"
    
    doFirst {
        println("Selected obfuscation tool: $OBFUSCATION_TOOL")
    }
    
    if (OBFUSCATION_TOOL.equals("R8", ignoreCase = true)) {
        dependsOn("r8")
    } else {
        dependsOn("proguard")
    }
}

tasks.register<Exec>("buildDexFromObfuscatedJar") {
    group = "build"
    description = "Build DEX from obfuscated JAR"
    dependsOn("obfuscate")
    
    val obfuscatedJar = when {
        OBFUSCATION_TOOL.equals("R8", ignoreCase = true) -> {
            File(layout.buildDirectory.get().asFile, "outputs/r8/${PLUGIN_NAME}-obfuscated.jar")
        }
        else -> {
            File(layout.buildDirectory.get().asFile, "outputs/proguard/${PLUGIN_NAME}-obfuscated.jar")
        }
    }
    
    val dexDir = File(layout.buildDirectory.get().asFile, "outputs/dex")
    
    doFirst {
        dexDir.mkdirs()
        validateBuildEnvironment()
        obfuscatedJar.ensureExists("Obfuscated JAR")
        
        println("Building DEX from obfuscated JAR: ${obfuscatedJar.name}")
        println("Obfuscation tool: $OBFUSCATION_TOOL")
    }
    
    workingDir = project.rootDir
    
    val d8Command = if (File(D8_BAT_PATH).exists()) {
        listOf(
            D8_BAT_PATH,
            "--release",
            "--min-api", MIN_SDK_VERSION.toString(),
            "--lib", ANDROID_JAR_PATH,
            "--output", dexDir.absolutePath,
            obfuscatedJar.absolutePath
        )
    } else {
        listOf(
            JAVA_EXEC_PATH, "-jar", D8_JAR_PATH,
            "--release",
            "--min-api", MIN_SDK_VERSION.toString(),
            "--lib", ANDROID_JAR_PATH,
            "--output", dexDir.absolutePath,
            obfuscatedJar.absolutePath
        )
    }
    
    commandLine = d8Command
    
    doLast {
        validateDexOutput(dexDir)
    }
}

tasks.named<JavaCompile>("compileJava") {
    options.compilerArgs.addAll(listOf("--release", JAVA_VERSION_NUMBER))
    
    doFirst {
        val androidJar = File(ANDROID_JAR_PATH)
        if (androidJar.exists()) {
            classpath = classpath.plus(files(androidJar))
            println("Android classpath added: ${androidJar.name}")
        } else {
            throw GradleException("Android JAR not found: ${androidJar.absolutePath}")
        }
    }
}

tasks.withType<JavaCompile>().configureEach {
    options.isFork = true
    options.forkOptions.executable = JAVAC_EXEC_PATH
}

tasks.register("checkEnvironment") {
    group = "verification"
    description = "Validate build environment configuration"
    
    doLast {
        printEnvironmentInfo()
    }
}

tasks.register("cleanDex") {
    group = "cleanup"
    description = "Clean DEX output directory"
    
    doLast {
        val dexDir = File(layout.buildDirectory.get().asFile, "outputs/dex")
        if (dexDir.exists()) {
            dexDir.deleteRecursively()
            println("Cleaned DEX directory")
        }
    }
}

tasks.register("cleanR8") {
    group = "cleanup"
    description = "Clean R8 output directory"
    
    doLast {
        val r8Dir = File(layout.buildDirectory.get().asFile, "outputs/r8")
        if (r8Dir.exists()) {
            r8Dir.deleteRecursively()
            println("Cleaned R8 directory")
        }
    }
}

tasks.register("cleanProguard") {
    group = "cleanup"
    description = "Clean ProGuard output directory"
    
    doLast {
        val proguardDir = File(layout.buildDirectory.get().asFile, "outputs/proguard")
        if (proguardDir.exists()) {
            proguardDir.deleteRecursively()
            println("Cleaned ProGuard directory")
        }
    }
}

tasks.named("clean") {
    dependsOn("cleanDex", "cleanR8", "cleanProguard", "cleanObfuscationFiles")
}

tasks.register("buildAll") {
    group = "build"
    description = "Complete build process with optional obfuscation"
    
    if (ENABLE_OBFUSCATION) {
        dependsOn("obfuscate", "buildDexFromObfuscatedJar")
    } else {
        dependsOn("jar", "buildDexFromJar")
    }
    
    finalizedBy("cleanObfuscationFiles")
    
    doLast {
        val buildDir = layout.buildDirectory.get().asFile
        val outputDir = File(project.rootDir, "output").apply { mkdirs() }
        
        val results = mutableListOf<Pair<String, File>>()
        
        if (ENABLE_OBFUSCATION) {
            val obfuscatedJar = when {
                OBFUSCATION_TOOL.equals("R8", ignoreCase = true) -> {
                    File(buildDir, "outputs/r8/${PLUGIN_NAME}-obfuscated.jar")
                }
                else -> {
                    File(buildDir, "outputs/proguard/${PLUGIN_NAME}-obfuscated.jar")
                }
            }
            val dexFile = File(buildDir, "outputs/dex/classes.dex")
            
            if (obfuscatedJar.exists()) {
                val outputJar = File(outputDir, "$PLUGIN_NAME-$PLUGIN_VERSION.jar")
                obfuscatedJar.copyTo(outputJar, overwrite = true)
                results.add("Obfuscated JAR" to outputJar)
            }
            
            if (dexFile.exists()) {
                val outputDex = File(outputDir, "$PLUGIN_NAME-$PLUGIN_VERSION.dex")
                dexFile.copyTo(outputDex, overwrite = true)
                results.add("Obfuscated DEX" to outputDex)
            }
        } else {
            val jarFile = tasks.jar.get().archiveFile.get().asFile
            val dexFile = File(buildDir, "outputs/dex/classes.dex")
            
            if (jarFile.exists()) {
                jarFile.copyTo(File(outputDir, jarFile.name), overwrite = true)
                results.add("JAR" to jarFile)
            }
            
            if (dexFile.exists()) {
                val outputDex = File(outputDir, "$PLUGIN_NAME-$PLUGIN_VERSION.dex")
                dexFile.copyTo(outputDex, overwrite = true)
                results.add("DEX" to outputDex)
            }
        }
        
        println("✓ Build completed successfully!")
        println("Output files:")
        results.forEach { (type, file) ->
            println("  - $type: ${file.name} (${file.length()} bytes)")
        }
        
        if (results.isEmpty()) {
            println("⚠ No output files were created - check build logs")
        }
    }
}

fun validateDexOutput(dexDir: File) {
    val dexFile = File(dexDir, "classes.dex")
    if (dexFile.exists()) {
        println("✓ DEX file created: ${dexFile.length()} bytes")
    } else {
        println("✗ DEX file not found in: ${dexDir.absolutePath}")
        dexDir.listFiles()?.forEach { file ->
            println("  - ${file.name} (${file.length()} bytes)")
        }
        throw GradleException("DEX compilation failed")
    }
}

fun printEnvironmentInfo() {
    println("Build Environment:")
    println("  Plugin: $PLUGIN_NAME v$PLUGIN_VERSION")
    println("  Obfuscation: ${if (ENABLE_OBFUSCATION) "ENABLED ($OBFUSCATION_TOOL)" else "DISABLED"}")
    println("  Min SDK: $MIN_SDK_VERSION, Compile SDK: $COMPILE_SDK_VERSION")
    println("  Java: $JAVA_VERSION_NUMBER")
    
    val checks = listOf(
        "Java Exec" to File(JAVA_EXEC_PATH),
        "Javac Exec" to File(JAVAC_EXEC_PATH),
        "D8 Tool" to (File(D8_BAT_PATH).takeIf { it.exists() } ?: File(D8_JAR_PATH)),
        "Android JAR" to File(ANDROID_JAR_PATH),
        "ProGuard" to File(PROGUARD_JAR_PATH),
        "ProGuard Config" to File(PROGUARD_CONFIG_FILE)
    )
    
    checks.forEach { (name, file) ->
        println("  $name: ${if (file.exists()) "✓" else "✗"}")
    }
    
    val javaFiles = project.fileTree("src/main/java") { include("**/*.java") }
    println("  Java Sources: ${javaFiles.files.size} files")
}