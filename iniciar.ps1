$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$env:JAVA_HOME = 'C:\Program Files\Java\jdk-17'
if (-not (Test-Path "$env:JAVA_HOME\bin\java.exe")) { throw 'Se requiere JDK 17 en JAVA_HOME; ajusta su ruta en iniciar.ps1.' }
$toolsDir = Join-Path $PSScriptRoot '.tools'
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null
$mavenDir = Join-Path $toolsDir 'apache-maven-3.9.9'
$tomcatDir = Join-Path $toolsDir 'apache-tomcat-10.1.61'
if (-not (Test-Path "$mavenDir\bin\mvn.cmd")) {
    Invoke-WebRequest 'https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.9/apache-maven-3.9.9-bin.zip' -OutFile "$toolsDir\maven.zip"
    Expand-Archive "$toolsDir\maven.zip" -DestinationPath $toolsDir -Force
}
if (-not (Test-Path "$tomcatDir\bin\bootstrap.jar")) {
    Invoke-WebRequest 'https://repo.maven.apache.org/maven2/org/apache/tomcat/tomcat/10.1.61/tomcat-10.1.61.zip' -OutFile "$toolsDir\tomcat.zip"
    Expand-Archive "$toolsDir\tomcat.zip" -DestinationPath $toolsDir -Force
}
$configPath = Join-Path $tomcatDir 'conf\server.xml'
$config = Get-Content -Raw $configPath
$config = $config.Replace('port="8080"', 'address="127.0.0.1" port="8090"').Replace('port="8005"', 'port="-1"')
[IO.File]::WriteAllText($configPath, $config)
if (Get-NetTCPConnection -LocalPort 8090 -State Listen -ErrorAction SilentlyContinue) {
    Write-Host 'El puerto 8090 ya está en uso. Si el taller está activo, abre http://localhost:8090/taller-jsf/'
    exit 0
}
& "$mavenDir\bin\mvn.cmd" -B package
if ($LASTEXITCODE -ne 0) { throw 'La compilación falló.' }
Copy-Item 'target\taller-jsf.war' "$tomcatDir\webapps\taller-jsf.war" -Force
$arguments = @('-Dfile.encoding=UTF-8', "-Dcatalina.home=$tomcatDir", "-Dcatalina.base=$tomcatDir", '-cp', "$tomcatDir\bin\bootstrap.jar;$tomcatDir\bin\tomcat-juli.jar", 'org.apache.catalina.startup.Bootstrap', 'start')
$quotedArguments = $arguments | ForEach-Object { '"' + $_ + '"' }
$process = Start-Process -FilePath "$env:JAVA_HOME\bin\java.exe" -ArgumentList $quotedArguments -WindowStyle Hidden -PassThru -RedirectStandardOutput "$toolsDir\servidor.log" -RedirectStandardError "$toolsDir\servidor-error.log"
$process.Id | Set-Content "$toolsDir\servidor.pid"
Write-Host 'Servidor iniciado: http://localhost:8090/taller-jsf/'
Write-Host 'Consola: .tools\servidor.log'
