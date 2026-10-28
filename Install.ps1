[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$appName = 'BingWallpaper'
$installDir = Join-Path $env:LOCALAPPDATA $appName
$sourceDir = $PSScriptRoot
$domainUser = "$env:USERDOMAIN\$env:USERNAME"

if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

Copy-Item -Path (Join-Path $sourceDir 'Get-BingWallpaper.ps1') -Destination (Join-Path $installDir 'Get-BingWallpaper.ps1') -Force
Copy-Item -Path (Join-Path $sourceDir 'config.json') -Destination (Join-Path $installDir 'config.json') -Force

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$installDir\Get-BingWallpaper.ps1`""
$triggerDaily = New-ScheduledTaskTrigger -Daily -At '08:00'
$triggerLogon = New-ScheduledTaskTrigger -AtLogOn -User $domainUser
$principal = New-ScheduledTaskPrincipal -UserId $domainUser -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd

$task = New-ScheduledTask -Action $action -Trigger $triggerDaily, $triggerLogon -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName $appName -InputObject $task -Force

Write-Host "Installed to $installDir"
Write-Host "Scheduled task '$appName' created."
