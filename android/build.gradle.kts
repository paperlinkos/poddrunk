allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

fun configureSubproject(p: Project) {
    if (p.plugins.hasPlugin("com.android.library")) {
        val manifestFile = p.file("src/main/AndroidManifest.xml")
        if (manifestFile.exists()) {
            val content = manifestFile.readText()
            if (content.contains("package=")) {
                val updated = content.replace(Regex("""package\s*=\s*"[^"]*""""), "")
                manifestFile.writeText(updated)
            }
        }
        val androidExt = p.extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
        if (androidExt != null) {
            if (androidExt.namespace == null) {
                androidExt.namespace = "com.poddrunk.plugin." + p.name.replace("-", "_")
            }
            androidExt.compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
    p.tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

subprojects {
    if (state.executed) {
        configureSubproject(this)
    } else {
        afterEvaluate { configureSubproject(this) }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
