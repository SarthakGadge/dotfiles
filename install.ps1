# Run this script as Administrator to link your dotfiles
winget install Starship.Starship --silent
winget install AmN.yasb --silent
winget install LGUG2Z.komorebi --silent


$DOTFILES = "$HOME\dotfiles"

$links = @{
    # Repo Path                                 # Actual App Path
    "$DOTFILES\komorebi\komorebi.json"      = "$HOME\komorebi.json"
    "$DOTFILES\komorebi\komorebi.bar.json"  = "$HOME\komorebi.bar.json"
    "$DOTFILES\starship\starship.toml"      = "$HOME\.config\starship.toml"
    "$DOTFILES\yasb\config.yaml"            = "$HOME\.config\yasb\config.yaml"
    "$DOTFILES\yasb\styles.css"             = "$HOME\.config\yasb\styles.css"
    "$DOTFILES\whkdrc\whkdrc"             = "$HOME\.config\whkdrc"
}

Write-Host "Starting Symlink process..." -ForegroundColor Cyan

$links.GetEnumerator() | ForEach-Object {
    $source = $_.Key
    $dest = $_.Value

    # Create destination directory if it doesn't exist
    $parent = Split-Path $dest
    if (!(Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force
    }

    # Remove existing file/link to avoid errors
    if (Test-Path $dest) {
        Write-Host "Removing existing file at $dest" -ForegroundColor Yellow
        Remove-Item $dest -Force
    }

    # Create the Symlink
    New-Item -ItemType SymbolicLink -Path $dest -Target $source
    Write-Host "Linked $dest -> $source" -ForegroundColor Green
}

Write-Host "Setup Complete!" -ForegroundColor Magenta
echo "Starting komorebic, yasb"
komorebic start --whkd
yasb
$profileCode = @"

# --- Added by Dotfiles Install Script ---
function Invoke-Starship-TransientFunction {
    &starship module character
}

Invoke-Expression (&starship init powershell)
Enable-TransientPrompt

function touch { New-Item -ItemType File -Path `$args -Force }
# ----------------------------------------
"@

Write-Host "Updating PowerShell Profile..." -ForegroundColor Cyan
# Check if the profile already contains starship init to prevent double-entry
if (Select-String -Path $PROFILE -Pattern "starship init" -Quiet) {
    Write-Host "Profile already configured. Skipping append." -ForegroundColor Yellow
} else {
    Add-Content -Path $PROFILE -Value $profileCode
    Write-Host "Profile updated successfully!" -ForegroundColor Green
}
Write-Host "Configuring Startup Tasks for Komorebi and YASB..." -ForegroundColor Cyan

# 1. Schedule Komorebi
$komorebiAction = New-ScheduledTaskAction -Execute "komorebic.exe" -Argument "start --whkd"
$komorebiTrigger = New-ScheduledTaskTrigger -AtLogOn
$komorebiSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Priority 0

Register-ScheduledTask -TaskName "KomorebiStartup" -Action $komorebiAction -Trigger $komorebiTrigger -Settings $komorebiSettings -Force

# 2. Schedule YASB
$yasbAction = New-ScheduledTaskAction -Execute "yasb.exe"
$yasbTrigger = New-ScheduledTaskTrigger -AtLogOn
$yasbSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Priority 0

Register-ScheduledTask -TaskName "YASBStartup" -Action $yasbAction -Trigger $yasbTrigger -Settings $yasbSettings -Force

Write-Host "Startup tasks scheduled successfully!" -ForegroundColor Green
echo "Ending script"

. $profile
