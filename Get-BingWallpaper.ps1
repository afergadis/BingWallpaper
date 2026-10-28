[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$configPath = Join-Path $PSScriptRoot 'config.json'

$market = 'en-US'
$res = 'UHD'
$imageFolder = Join-Path (Join-Path $env:LOCALAPPDATA 'BingWallpaper') 'images'

if (Test-Path $configPath) {
    try {
        $cfg = Get-Content $configPath -Raw | ConvertFrom-Json
        if ($cfg.market) { $market = $cfg.market }
        if ($cfg.resolution) { $res = $cfg.resolution }
        if ($cfg.imageFolder) { $imageFolder = [Environment]::ExpandEnvironmentVariables($cfg.imageFolder) }
    } catch {
        Write-Warning "config.json is invalid: $_"
    }
}

if (-not (Test-Path $imageFolder)) {
    New-Item -ItemType Directory -Path $imageFolder -Force | Out-Null
}

$appFolder = Split-Path $imageFolder -Parent
$lastRunFile = Join-Path $appFolder 'lastrun.txt'

if (Test-Path $lastRunFile) {
    $lastRun = Get-Content $lastRunFile -Raw
    if ($lastRun -eq (Get-Date -Format 'yyyy-MM-dd')) {
        Write-Host 'Wallpaper already updated today.'
        exit 0
    }
}

$uhdParams = ''
if ($res -eq 'UHD') {
    $uhdParams = '&uhd=1&uhdwidth=3840&uhdheight=2160'
}

$uri = "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=$market$uhdParams"
$resp = Invoke-WebRequest -Uri $uri -UseBasicParsing -Headers @{'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
$json = $resp.Content | ConvertFrom-Json

if (-not $json.images -or $json.images.Count -eq 0) {
    throw 'No image returned from Bing.'
}

$img = $json.images[0]
$url = $img.url
if ($url -notmatch '^https?://') {
    $url = "https://www.bing.com$url"
}

$fileName = 'bing_' + (Get-Date -Format 'yyyy-MM-dd') + '.jpg'
$outPath = Join-Path $imageFolder $fileName

Invoke-WebRequest -Uri $url -UseBasicParsing -OutFile $outPath

Add-Type @'
using System;
using System.Runtime.InteropServices;
public class BingWallpaper_Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
'@

$SPI_SETDESKWALLPAPER = 0x14
$SPIF_UPDATEINIFILE = 0x01
$SPIF_SENDCHANGE = 0x02
$null = [BingWallpaper_Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $outPath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)

Get-Date -Format 'yyyy-MM-dd' | Set-Content -Path $lastRunFile -NoNewline

Get-ChildItem -Path $imageFolder -Filter 'bing_*.jpg' -File -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
    Remove-Item -Force

Write-Host "Wallpaper set: $outPath"
