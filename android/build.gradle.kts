allprojects {
    repositories {
        google()
        mavenCentral()
        // ✅ إضافة repository لـ ffmpeg-kit
        maven {
            url = uri("https://www.jitpack.io")
        }
        // ✅ إضافة repository إضافي لـ ffmpeg-kit
        maven {
            url = uri("https://repo1.maven.org/maven2")
        }
        // ✅ إضافة Maven repository لـ FFmpeg Kit
        maven {
            url = uri("https://oss.sonatype.org/content/repositories/snapshots/")
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
