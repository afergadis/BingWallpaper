[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$appName = 'BingWallpaper'
$installDir = Join-Path $env:LOCALAPPDATA $appName

$task = Get-ScheduledTask -TaskName $appName -ErrorAction SilentlyContinue
if ($task) {
    Unregister-ScheduledTask -TaskName $appName -Confirm:$false
    Write-Host "Removed scheduled task '$appName'."
}

if (Test-Path $installDir) {
    Remove-Item -Path $installDir -Recurse -Force
    Write-Host "Removed $installDir."
}
