function play {
    param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Rest)

    # подсказочка
    if (-not $Rest -or $Rest.Count -eq 0) {
        Write-Host "Использование: play <файл|маска|URL> [доп.параметры mpv]"
        return
    }

    # шаманство с громкостью (если заранее задать то не прокает установка на 35 кароче) 
    $userSetVolume = $false
    for ($i = 0; $i -lt $Rest.Count; $i++) {
        if ($Rest[$i] -match '^--volume(=|\s*)\d+$') { $userSetVolume = $true; break }
        if ($Rest[$i] -eq '--volume' -and ($i + 1) -lt $Rest.Count -and $Rest[$i+1] -match '^\d+$') {
            $userSetVolume = $true; break
        }
    }

    $expanded = @()
    foreach ($arg in $Rest) {
        if ($arg -like '-*') {
            $expanded += $arg
        } elseif ($arg -match '[\*\?]') {
            $paths = Resolve-Path -Path $arg -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path
            if ($paths) { $expanded += $paths }
        } else {
            $expanded += $arg
        }
    }

    if ($expanded.Count -eq 0) {
        Write-Host "Ничего не найдено по маске/пути: $($Rest -join ' ')"
        return
    }

    $base = @('--no-video')
    if (-not $userSetVolume) { $base += '--volume=35' }

    mpv @base @expanded
}


# смешная настройка цветов консоли ===

if (Get-Module -ListAvailable PSReadLine) {
    Set-PSReadLineOption -Colors @{
        Command          = 'DarkBlue'
        Parameter        = 'DarkCyan'
        String           = 'DarkGreen'
        Operator         = 'DarkGray'
        Variable         = 'DarkMagenta'
        Number           = 'DarkRed'
        Type             = 'DarkCyan'
        Member           = 'DarkBlue'
        Keyword          = 'DarkMagenta'
        Comment          = 'Gray'
        Emphasis         = 'DarkRed'
        Error            = 'Red'
        Selection        = 'Gray'
        InlinePrediction = 'DarkGray'
    }
}

$PSStyle.FileInfo.Script   = $PSStyle.Foreground.DarkCyan
$PSStyle.FileInfo.Extension['.ps1']  = $PSStyle.Foreground.DarkCyan
$PSStyle.FileInfo.Extension['.psm1'] = $PSStyle.Foreground.DarkCyan
$PSStyle.FileInfo.Extension['.psd1'] = $PSStyle.Foreground.DarkCyan
$PSStyle.Formatting.TableHeader = $PSStyle.Foreground.DarkBlue

