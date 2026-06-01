# Restore Claudian main.js to the most recent pre-patch backup.
# Usage:  ./uninstall.ps1 -VaultPath "D:\path\to\your\ObsidianVault"
param(
  [Parameter(Mandatory = $true)]
  [string]$VaultPath
)
$ErrorActionPreference = 'Stop'
$pluginDir = Join-Path $VaultPath '.obsidian\plugins\claudian'
$target = Join-Path $pluginDir 'main.js'
$last = Get-ChildItem $pluginDir -Filter 'main.js.bak-before-image-autosave-*' -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending | Select-Object -First 1
if (-not $last) { Write-Host "[ERR] no pre-patch backup found in $pluginDir"; exit 1 }
Copy-Item $last.FullName $target -Force
Write-Host "[OK] restored $($last.Name) -> main.js. Restart Obsidian to take effect."
