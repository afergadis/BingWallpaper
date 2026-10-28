# BingWallpaper

A tiny Windows tool that downloads Bing’s image of the day and sets it as your desktop wallpaper. It runs once per day via a scheduled task—no background service, no large install.

## Files

- `Get-BingWallpaper.ps1` — downloads the image and sets the wallpaper.
- `Install.ps1` / `Install.bat` — installs the script and creates the scheduled task.
- `Uninstall.ps1` / `Uninstall.bat` — removes the task and files.
- `config.json` — settings (market, resolution, image folder).

## Install

Right-click `Install.bat` and choose **Run as administrator** if Windows asks, then:

```bat
Install.bat
```

Or from PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\Install.ps1
```

This creates:

- A folder in `%LOCALAPPDATA%\BingWallpaper`
- A scheduled task named `BingWallpaper` that runs daily at 08:00 and at logon

## Configure

Edit `%LOCALAPPDATA%\BingWallpaper\config.json`:

```json
{
  "market": "en-US",
  "resolution": "UHD",
  "imageFolder": "%LOCALAPPDATA%\\BingWallpaper\\images"
}
```

- `market`: Bing market code, e.g. `en-US`, `en-GB`, `de-DE`, `fr-FR`.
- `resolution`: `UHD` for 4K or `1920x1080` for full-HD.
- `imageFolder`: where wallpapers are saved.

## Run manually

```powershell
powershell -ExecutionPolicy Bypass -File "%LOCALAPPDATA%\BingWallpaper\Get-BingWallpaper.ps1"
```

## Uninstall

Run `Uninstall.bat` or `Uninstall.ps1`.
