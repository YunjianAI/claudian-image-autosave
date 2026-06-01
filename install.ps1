# Claudian image-autosave patch installer (based on Claudian 2.0.1)
# Backs up the current main.js, then installs the patched one.
# Usage:  ./install.ps1 -VaultPath "D:\path\to\your\ObsidianVault"
param(
  [Parameter(Mandatory = $true)]
  [string]$VaultPath
)
$ErrorActionPreference = 'Stop'
$pluginDir = Join-Path $VaultPath '.obsidian\plugins\claudian'
$target  = Join-Path $pluginDir 'main.js'
$newMain = Join-Path $PSScriptRoot 'main.js'
if (-not (Test-Path $target))  { Write-Host "[ERR] Claudian main.js not found at: $target  (check -VaultPath)"; exit 1 }
if (-not (Test-Path $newMain)) { Write-Host "[ERR] patched main.js not found beside this script"; exit 1 }
$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = Join-Path $pluginDir "main.js.bak-before-image-autosave-$ts"
Copy-Item $target $backup -Force
Write-Host "[OK] backed up current main.js -> $($backup | Split-Path -Leaf)"
Copy-Item $newMain $target -Force
Write-Host "[OK] installed image-autosave main.js. Restart Obsidian (or Reload app) to load it."
Write-Host "[NEXT] Paste an image in a Claudian chat, then check <vault>/99.对话图片/"
Write-Host "[NOTE] If you use claudian-tab-title-patch, re-run it after this (this overwrites main.js)."
