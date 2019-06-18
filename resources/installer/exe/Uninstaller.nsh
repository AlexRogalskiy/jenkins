RequestExecutionLevel user

# Macro for selecting uninstaller sections
!macro HideUnsection SECTION_NAME UNSECTION_ID
    ReadRegStr $0 HKLM "${REGKEY}\Components" "${SECTION_NAME}"

    ${if} ${Errors}
    ${orIf} $0 == ""
        !insertmacro HideSection ${UNSECTION_ID}
    ${endIf}
!macroend

# Uninstaller sections
Section "!un.${PLATFORM_SECTION_NAME}" UnSecPlatform
    SectionIn RO
SectionEnd

Section /o "un.${JAVA_SECTION_NAME}" UnSecJava
    SectionIn RO
SectionEnd

Section /o "un.${PG_SECTION_NAME}" UnSecPG
SectionEnd

Section /o "un.${IDEA_SECTION_NAME}" UnSecIdea
SectionEnd

Section /o "un.${JASPER_SECTION_NAME}" UnSecJasper
SectionEnd

Section -un.Uninstall
    ; has to be first string by spec
    Delete /REBOOTOK $INSTDIR\uninstall.exe

    ${if} ${FileExists} "$INSTDIR\bin\lsfusion.exe"
        DetailPrint "Removing lsFusion Server service"
        ReadRegStr $0 HKLM "${REGKEY}" "serverServiceName"
        ${ifNot} ${Errors}
        ${andIfNot} $0 == ""
            nsExec::ExecToLog '"$INSTDIR\bin\lsfusion.exe" //DS//$0'
        ${else}
            DetailPrint "Can't find lsFusion Server service information in registry"
        ${endIf}
    ${endIf}


    ReadRegStr $0 HKLM "${REGKEY}" "tomcatInstallDir"
    ${ifNot} ${Errors}
    ${andIfNot} $0 == ""
        DetailPrint "Removing Apache Tomcat"
        
        DetailPrint "Removing tomcat service"
        ReadRegStr $1 HKLM "${REGKEY}" "clientServiceName"
        ${ifNot} ${Errors}
        ${andIfNot} $1 == ""
            nsExec::ExecToLog '"$0\bin\tomcat${TOMCAT_MAJOR_VERSION}.exe" //DS//$1'
        ${else}
            DetailPrint "Can't find Apache Tomcat service information in registry"
        ${endIf}

        DetailPrint "Removing tomcat directory"
        RMDir /r $0
    ${endIf}
    
    ${if} ${SectionIsSelected} ${UnSecPG}
        ReadRegStr $0 HKLM "${REGKEY}" "postgreInstallDir"
        ${ifNot} ${Errors}
        ${andIfNot} $0 == ""
        ${andIf} ${FileExists} "$0\uninstall-postgresql.exe"
            DetailPrint "Removing PostgreSQL"
            nsExec::ExecToLog '"$0\uninstall-postgresql.exe" --mode unattended'
        ${endIf}
    ${endIf}
        
    ${if} ${SectionIsSelected} ${UnSecIdea}
        ReadRegStr $0 HKLM "${REGKEY}" "ideaInstallDir"
        ${ifNot} ${Errors}
        ${andIfNot} $0 == ""
        ${andIf} ${FileExists} "$0\bin\Uninstall.exe"
            DetailPrint "Removing Intellij IDEA"
            nsExec::ExecToLog "$0\bin\Uninstall.exe /S"
            
            Delete "$DESKTOP\IntelliJ IDEA Community Edition ${IDEA_VERSION}.lnk"
            Delete "$SMPROGRAMS\JetBrains\IntelliJ IDEA Community Edition ${IDEA_VERSION}.lnk"
            RMDir "$SMPROGRAMS\JetBrains"
        ${endIf}
    ${endIf}
    
    ${if} ${SectionIsSelected} ${UnSecJasper}
        ReadRegStr $0 HKLM "${REGKEY}" "jaspersoftStudioInstallDir"
        DetailPrint "Jaspersoft Studio jasperDir: $0"
        ${ifNot} ${Errors}
        ${andIfNot} $0 == ""
        ${andIf} ${FileExists} "$0\uninst.exe"
            DetailPrint "Removing Jaspersoft Studio"
            nsExec::ExecToLog "$0\uninst.exe /S"
        ${endIf}
    ${endIf}
        
    DetailPrint "Cleaning registry"
    DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)"
    DeleteRegKey HKLM "${REGKEY}"

    DetailPrint "Removing shortcuts"
    Delete "$DESKTOP\lsFusion Web Client.lnk"
    Delete "$DESKTOP\lsFusion Desktop Client.lnk"
    RMDir /r "$SMPROGRAMS\lsFusion ${LSFUSION_MAJOR_VERSION}"


    DetailPrint "Removing program directory"
    RmDir /r $INSTDIR
SectionEnd

# Uninstaller functions
Function un.onInit
    SetRegView ${ARCH}

    ReadRegStr $INSTDIR HKLM "${REGKEY}" Path

    !insertmacro MUI_UNGETLANGUAGE

    !insertmacro HideUnsection "${PG_SECTION_NAME}" ${UnSecPG}
    !insertmacro HideUnsection "${IDEA_SECTION_NAME}" ${UnSecIdea}
    !insertmacro HideUnsection "${JASPER_SECTION_NAME}" ${UnSecJasper}
    !insertmacro HideUnsection "${JAVA_SECTION_NAME}" ${UnSecJava}
FunctionEnd

# Section Descriptions
!insertmacro MUI_UNFUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${UnSecPlatform} $(strPlatformUnSectionDescription)
!insertmacro MUI_DESCRIPTION_TEXT ${UnSecPG} $(strPgUnSectionDescription)
!insertmacro MUI_DESCRIPTION_TEXT ${UnSecIdea} $(strIdeaUnSectionDescription)
!insertmacro MUI_DESCRIPTION_TEXT ${UnSecJasper} $(strJasperUnSectionDescription)
!insertmacro MUI_DESCRIPTION_TEXT ${UnSecJava} $(strJavaUnSectionDescription)
!insertmacro MUI_UNFUNCTION_DESCRIPTION_END
