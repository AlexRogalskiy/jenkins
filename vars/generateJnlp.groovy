def call(String platformVersion) {
    def downloadDir = "${Paths.download}/${platformVersion}"
    sh "mkdir -p ${downloadDir}"
    
    sh "cp -fa web-api/src/main/resources/client.jnlp ${downloadDir}/lsfusion-client-${platformVersion}.jnlp"

    sh """sed -i -e 's|\${jnlp.codebase}|http://download.lsfusion.org/${platformVersion}|' \\
-e "s/\$\"{jnlp.url}\"/lsfusion-client-${platformVersion}.jnlp/" \\
-e 's|\${jnlp.appName}|lsFusion|' \\
-e 's|\${jnlp.initHeapSize}|256m|' \\
-e 's|\${jnlp.maxHeapSize}|1024m|' \\
-e 's|\${jnlp.maxHeapFreeRatio}|70|' \\
-e 's|\${jnlp.vmargs}||' \\
-e 's|\${jnlp.registryHost}|localhost|' \\
-e 's|\${jnlp.registryPort}|7652|' \\
-e 's|\${jnlp.exportName}|default|' \\
-e 's|\${jnlp.singleInstance}|false|' \\
-e "s|lsfusion-client.jar|lsfusion-client-${platformVersion}.jar|" ${downloadDir}/lsfusion-client-${platformVersion}.jnlp"""
}

