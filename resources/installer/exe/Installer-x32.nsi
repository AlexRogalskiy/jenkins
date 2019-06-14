!define ARCH 32

!include Versions.nsh

!define JAVA_INSTALLER "jdk-${JDK_DISTRVERSION}-windows-i586.exe"
!define PG_INSTALLER "postgresql-${PG_VERSION}${PG_MINORVERSION}-1-windows.exe"
!define IDEA_INSTALLER "ideaIC-${IDEA_VERSION}.exe"
!define IDEA_PLUGIN "lsfusion-idea-plugin.zip"
!define IDEA_EXE "idea.exe"
!define TOMCAT_ARCHIVE "apache-tomcat-${TOMCAT_FULL_VERSION}-windows-x86.zip"
!define ANT_ARCHIVE "apache-ant-1.9.2.zip"
!define JASPER_INSTALLER "TIB_js-studiocomm_${JASPER_VERSION}.final_windows_x86.exe"

!ifndef OUT_FILE
;    !define OUT_FILE "lsfusion-setup-x32.exe"
    !define OUT_FILE "x32.exe"
!endif

!include Installer.nsh
