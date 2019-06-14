
;!define SKIP_FILES 1

# Installer sections
SubSection "!${PLATFORM_SECTION_NAME}" SecPlatform
    Section -CoreFiles
        DetailPrint "Begin installation"
        
        SetOutPath ${INSTBINDIR}
        SetOverwrite on
        
        ${SFile} install-bin\${ANT_ARCHIVE}
        
        DetailPrint "Extracting Ant to ${INSTBINDIR}"
        
        nsisunz::Unzip "${INSTBINDIR}\${ANT_ARCHIVE}" "${INSTBINDIR}"
        Pop $0
        StrCmp $0 "success" ok
          DetailPrint "$0" ;print error message to log
          Abort
        ok:

        Delete "${INSTBINDIR}\${ANT_ARCHIVE}"

        SetOutPath ${INSTCONFDIR}
        File "install-config\*.*"
        
        SetOutPath $INSTDIR\resources
        File "resources\lsfusion.ico"
        
        ; TODO
;        File "resources\license-english.txt"
;        File "resources\license-russian.txt"

        SetOutPath $INSTDIR
        File /r "conf"
        File install-bin\${IDEA_PLUGIN}
    SectionEnd

    Section "${SERVER_SECTION_NAME}" SecServer
        SetOutPath $INSTDIR
        SetOverwrite on
        
        File /r "deploy"
        ${SFile} install-bin\${SERVER_JAR}
        ${SFile} install-bin\${SERVER_SOURCES_JAR}

        SetOutPath $INSTDIR\bin
        File /oname=lsfusion.exe bin\lsfusion${ARCH}.exe
        File /oname=lsfusion.exe bin\lsfusion${ARCH}.exe

        WriteRegStr HKLM "${REGKEY}\Components" "${SERVER_SECTION_NAME}" 1
    SectionEnd

    Section "${CLIENT_SECTION_NAME}" SecClient
        SetOutPath $INSTDIR
        SetOverwrite on
        
        ${SFile} install-bin\${CLIENT_JAR}
        
        WriteRegStr HKLM "${REGKEY}\Components" "${SERVER_SECTION_NAME}" 1
    SectionEnd
    
    Section "${WEBCLIENT_SECTION_NAME}" SecWebClient
        SetOutPath $INSTDIR
        SetOverwrite on
        
        ${SFile} install-bin\${WEBCLIENT_WAR}
        
        WriteRegStr HKLM "${REGKEY}\Components" "${SERVER_SECTION_NAME}" 1
    SectionEnd
    
    Section "${MENU_SECTION_NAME}" SecShortcuts
;        SectionIn 1 2 3
    SectionEnd
    
    Section "${SERVICES_SECTION_NAME}" SecServices
;        SectionIn 1 2 3
    SectionEnd
SubSectionEnd

Section "${JAVA_SECTION_NAME}" SecJava
    SetOutPath ${INSTBINDIR}
    SetOverwrite on

    ; install Java if no recent is installed
    ${if} $javaVersion == ""
        ${SFile} install-bin\${JAVA_INSTALLER}

        nsExec::ExecToLog '"${INSTBINDIR}\${JAVA_INSTALLER}" /s ADDLOCAL="ToolsFeature,SourceFeature,PublicjreFeature"'
        Pop $0

        Call initJavaFromRegistry
        ${if} $javaHome == ""
            DetailPrint "JDK wasn't isntalled succesfully: can't find javaHome in registry. Try to install JDK manually and restart installer"
            Abort
        ${endIf}

        WriteRegStr HKLM "${REGKEY}\Components" "${JAVA_SECTION_NAME}" 1

        Delete "${INSTBINDIR}\${JAVA_INSTALLER}"
    ${else}
        DetailPrint "Skipping Java installation"
    ${endif}
SectionEnd

Section "${PG_SECTION_NAME}" SecPG
    SetOutPath ${INSTBINDIR}
    SetOverwrite on

    ; Install PostgreSQL if no recent version is installed
    ${if} $pgVersion == ""
        ${SFile} install-bin\${PG_INSTALLER}

        nsExec::ExecToLog '"${INSTBINDIR}\${PG_INSTALLER}" --mode unattended --unattendedmodeui none --prefix "$pgDir" --datadir "$pgDir\data" --superpassword "$pgPassword" --serverport $pgPort --servicename "$pgServiceName"'
        Pop $0
        DetailPrint "PostgreSQL installation returned $0"
        
        WriteRegStr HKLM "${REGKEY}\Components" "${PG_SECTION_NAME}" 1
        WriteRegStr HKLM "${REGKEY}" "postgreInstallDir" "$pgDir"

        Delete "${INSTBINDIR}\${PG_INSTALLER}"
    ${else}
        DetailPrint "Skipping PostgreSQL installation"
    ${endif}
SectionEnd

Section "${TOMCAT_SECTION_NAME}" SecTomcat
    SetOutPath ${INSTBINDIR}
    SetOverwrite on

    ; install Tomcat if no recent is installed
    ${if} $tomcatVersion == ""
        ${SFile} install-bin\${TOMCAT_ARCHIVE}
        
        DetailPrint "Extracting Tomcat to $tomcatDir"
        
        nsisunz::Unzip "${INSTBINDIR}\${TOMCAT_ARCHIVE}" "$tomcatDir"
        Pop $0
        StrCmp $0 "success" ok
          DetailPrint "$0" ;print error message to log
        ok:

        WriteRegStr HKLM "${REGKEY}\Components" "${TOMCAT_SECTION_NAME}" 1
        WriteRegStr HKLM "${REGKEY}" "tomcatInstallDir" "$tomcatDir"

        Delete "${INSTBINDIR}\${TOMCAT_ARCHIVE}"
    ${else}
        DetailPrint "Skipping Apache Tomcat installation"
    ${endif}
SectionEnd

Section "${IDEA_SECTION_NAME}" SecIdea
    !ifdef DEV
        SetOutPath ${INSTBINDIR}
        SetOverwrite on
    
        ; Install PostgreSQL if no recent version is installed
        ${SFile} install-bin\${IDEA_INSTALLER}

        DetailPrint 'ExecWait "${INSTBINDIR}\${IDEA_INSTALLER}" /S /D=$ideaDir'
        nsExec::ExecToLog '"${INSTBINDIR}\${IDEA_INSTALLER}" /S /D=$ideaDir'
        Pop $0
        DetailPrint "IntelliJ Idea installation returned $0"
        
        WriteRegStr HKLM "${REGKEY}\Components" "${IDEA_SECTION_NAME}" 1
        WriteRegStr HKLM "${REGKEY}" "ideaInstallDir" "$ideaDir"

        Delete "${INSTBINDIR}\${IDEA_INSTALLER}"
    !endif
SectionEnd

Section "${JASPER_SECTION_NAME}" SecJasper
    !ifdef DEV
        SetOutPath ${INSTBINDIR}
        SetOverwrite on
    
        ${SFile} install-bin\${JASPER_INSTALLER}

        DetailPrint 'ExecWait "${INSTBINDIR}\${JASPER_INSTALLER}" /S /D=$jasperDir'
        nsExec::ExecToLog '"${INSTBINDIR}\${JASPER_INSTALLER}" /S /D=$jasperDir'
        Pop $0
        DetailPrint "Jaspersoft Studio installation returned $0"
        
        WriteRegStr HKLM "${REGKEY}\Components" "${JASPER_SECTION_NAME}" 1
        WriteRegStr HKLM "${REGKEY}" "jaspersoftStudioInstallDir" "$jasperDir"

        Delete "${INSTBINDIR}\${JASPER_INSTALLER}"
    !endif
SectionEnd

# Section Descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SecPlatform} $(strPlatformSectionDescription)
!insertmacro MUI_DESCRIPTION_TEXT ${SecServer} $(strServerSectionDescription)
!insertmacro MUI_DESCRIPTION_TEXT ${SecClient} $(strClientSectionDescription)
!insertmacro MUI_DESCRIPTION_TEXT ${SecWebClient} $(strWebClientSectionDescription)
!insertmacro MUI_DESCRIPTION_TEXT ${SecShortcuts} $(strShortcutsSectionDescription)
!insertmacro MUI_DESCRIPTION_TEXT ${SecServices} $(strServicesSectionDescription)
!insertmacro MUI_DESCRIPTION_TEXT ${SecPG} $(strPgSectionDescription)
!insertmacro MUI_DESCRIPTION_TEXT ${SecIdea} $(strIdeaSectionDescription)
!insertmacro MUI_DESCRIPTION_TEXT ${SecJasper} $(strJasperSectionDescription)
!insertmacro MUI_DESCRIPTION_TEXT ${SecJava} $(strJavaSectionDescription)
!insertmacro MUI_DESCRIPTION_TEXT ${SecTomcat} $(strTomcatSectionDescription)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

!insertmacro DefinePreFeatureFunction ${SecTomcat} tomcat
;!insertmacro DefinePreFeatureFunction ${SecJava} java
!insertmacro DefinePreFeatureFunction ${SecPG} pg
!insertmacro DefinePreFeatureFunction ${SecIdea} idea
!insertmacro DefinePreFeatureFunction ${SecJasper} jasper
