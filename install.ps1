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
    "$DOTFILES\yasb\config.yaml"            = "$HOME\.yasb\config.yaml"
    "$DOTFILES\yasb\styles.css"             = "$HOME\.yasb\styles.css"
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
