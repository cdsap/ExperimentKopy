plugins {
    `kotlin-dsl`
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.10")
    implementation("com.android.tools.build:gradle:8.8.0")
}

gradlePlugin {
    plugins {
        register("kotlinPlugin") {
            id = "awesome.kotlin.plugin"
            implementationClass = "com.logic.Plugin1"
        }
    }
}
gradlePlugin {
    plugins {
        register("androidLibPlugin") {
            id = "awesome.androidlib.plugin"
            implementationClass = "com.logic.CompositeBuildPluginAndroidLib"
        }
    }
}
gradlePlugin {
    plugins {
        register("androidAppPlugin") {
            id = "awesome.androidapp.plugin"
            implementationClass = "com.logic.CompositeBuildPluginAndroidApp"
        }
    }
}
