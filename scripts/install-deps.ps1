# scripts/install-deps.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Test-Cmd { param([string]$Name) return [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

function Ensure-Winget {
    if (Test-Cmd -Name 'winget') { return $true }
    Write-Host "❌ winget не найден. Установите 'App Installer' из Microsoft Store и запустите скрипт снова." -ForegroundColor Red
    Write-Host "Откройте: ms-windows-store://pdp/?productid=9NBLGGH4NNS1"
    return $false
}

function Install-IfMissing-WingetId {
    param([string]$Id, [string]$Friendly)
    $installed = (winget list --id $Id -e 2>$null) -notmatch "No installed package found"
    if ($installed) { Write-Host "✔ $Friendly уже установлен ($Id)"; return }
    Write-Host "⇢ Устанавливаю $Friendly ($Id)..." -ForegroundColor Yellow
    winget install --id $Id -e --silent --accept-package-agreements --accept-source-agreements
}

function Try-Install-Any {
    param([string[]]$Candidates, [string]$Friendly)
    foreach ($id in $Candidates) {
        try {
            $found = (winget show --id $id -e 2>$null) -notmatch "No package found"
            if ($found) {
                Install-IfMissing-WingetId -Id $id -Friendly $Friendly
                return $true
            }
        } catch { }
    }
    return $false
}

# === Основной поток ===
if (-not (Ensure-Winget)) { exit 1 }

# 1) FFmpeg
$null = Try-Install-Any -Candidates @(
    'FFmpeg.FFmpeg',   # официальный мета-пакет
    'Gyan.FFmpeg',
    'BtbN.FFmpeg'
) -Friendly 'FFmpeg'

# 2) yt-dlp
$null = Try-Install-Any -Candidates @(
    'yt-dlp.yt-dlp'
) -Friendly 'yt-dlp'

# 3) mpv 
$mpvOk = Try-Install-Any -Candidates @(
    'zhongyang219.Mpv.NET',  # mpv.net (часто доступен)
    'stax76.mpv.net',
    'shinchiro.mpv',         # чистый mpv (если доступен)
    'Ichiko121.MPV'
) -Friendly 'mpv'

if (-not $mpvOk) {
    Write-Host "⚠ mpv в winget не найден. Fallback через Chocolatey (опционально):" -ForegroundColor Yellow
    Write-Host '  Админ PowerShell:'
    Write-Host '    Set-ExecutionPolicy Bypass -Scope Process -Force; ' `
             '[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072; ' `
             "iex ((New-Object Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    Write-Host '    choco install mpv -y'
}

Write-Host "`nГотово. Проверка версий:" -ForegroundColor Green
if (Test-Cmd 'mpv')    { (mpv --version   | Select-Object -First 1) } else { Write-Host "mpv:    не найден" }
if (Test-Cmd 'yt-dlp') { (yt-dlp --version) }                         else { Write-Host "yt-dlp: не найден" }
if (Test-Cmd 'ffmpeg') { (ffmpeg -version | Select-Object -First 1) } else { Write-Host "ffmpeg: не найден" }

