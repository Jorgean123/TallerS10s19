$ErrorActionPreference = 'Stop'
$pidFile = Join-Path $PSScriptRoot '.tools\servidor.pid'
if (Test-Path $pidFile) {
    $serverProcessId = [int](Get-Content $pidFile)
    $serverProcess = Get-CimInstance Win32_Process -Filter "ProcessId = $serverProcessId"
    if ($serverProcess -and $serverProcess.Name -eq 'java.exe' -and $serverProcess.CommandLine.Contains((Join-Path $PSScriptRoot '.tools\apache-tomcat-10.1.61'))) {
        Stop-Process -Id $serverProcessId
        Write-Host 'Servidor del taller detenido.'
    }
    Remove-Item -LiteralPath $pidFile
}
