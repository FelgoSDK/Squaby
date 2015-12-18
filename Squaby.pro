# allows to add DEPLOYMENTFOLDERS and links to the V-Play library and QtCreator auto-completion
CONFIG += v-play

qmlFolder.source = qml
DEPLOYMENTFOLDERS += qmlFolder # comment for publishing

assetsFolder.source = assets
DEPLOYMENTFOLDERS += assetsFolder

# Add more folders to ship with the application here

RESOURCES += \
#    resources_Squaby.qrc # uncomment for publishing

# NOTE: for PUBLISHING, perform the following steps:
# 1. comment the DEPLOYMENTFOLDERS += qmlFolder line above, to avoid shipping your qml files with the application (instead they get compiled to the app binary)
# 2. uncomment the resources.qrc file inclusion and add any qml subfolders to the .qrc file; this compiles your qml files and js files to the app binary and protects your source code
# 3. change the setMainQmlFile() call in main.cpp to the one starting with "qrc:/" - this loads the qml files from the resources
# for more details see the "Deployment Guides" in the V-Play Documentation

# during development, use the qmlFolder deployment because you then get shorter compilation times (the qml files do not need to be compiled to the binary but are just copied)
# also, for quickest deployment on Desktop disable the "Shadow Build" option in Projects/Builds - you can then select "Run Without Deployment" from the Build menu in Qt Creator if you only changed QML files; this speeds up application start, because your app is not copied & re-compiled but just re-interpreted


# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp

# uncomment this to use the V-Play Plugins in Squaby
# NOTE: you can only enable the plugins, after installing them with the Qt installer
# see V-Play Plugins installation guide how to install the plugins on your PC:
# http://plugins.v-play.net/doc/plugin-installation/
# once you installed the plugins, you MUST enable this config!
# to run the demo with included plugins, you also need to modify the path to your Android SDK of these files:
# - vendor/facebook/local.properties
# - vendor/google-play-services_lib/local.properties
#CONFIG += includePlugins

android {

    includePlugins {

        LIBS += -lAdmobPlugin
        LIBS += -lFacebookPlugin
        LIBS += -lFlurryPlugin
        LIBS += -lSoomlaPlugin

        # the android-plugins folder has a different AndroidManifest and project.properties file
        ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android-plugins
        # so it gets displayed in QtCreator in the other files
        OTHER_FILES += android-plugins/AndroidManifest.xml
        OTHER_FILES += android-plugins/project.properties
    } else {

        ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
        OTHER_FILES += android/AndroidManifest.xml
    }
}

ios {
    QMAKE_INFO_PLIST = ios/Project-Info.plist
    OTHER_FILES += $$QMAKE_INFO_PLIST

    includePlugins {
        QMAKE_LFLAGS += -ObjC
        LIBS += -L$$PWD/ios # for AdMob & Flurry - the .a libs should be copied in this folder
        LIBS += -F~/Documents/FacebookSDK -framework FacebookSDK # for Facebook - if you choose another location in the FacebookSDK installation, use that one here
    }
}
