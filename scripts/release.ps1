# Clean, fetch packages, check, and build the signed prod release.
#
#   .\release.cmd                  APK + App Bundle (for Play)
#   .\release.cmd -Target apk      only the APK (to install directly)
#   .\release.cmd -Target bundle   only the App Bundle
#   .\release.cmd -Install         also install the APK on the connected phone
#   .\release.cmd -SkipChecks      skip analyze + tests (not recommended)
param(
    [ValidateSet('both', 'apk', 'bundle')] [string] $Target = 'both',
    [switch] $Install,
    [switch] $SkipChecks
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

if (Get-Command fvm -ErrorAction SilentlyContinue) {
    $flutter = @('fvm', 'flutter')
} else {
    $flutter = @('flutter')
}

function Step([string] $title, [string[]] $cmd) {
    Write-Host ''
    Write-Host "==> $title" -ForegroundColor Cyan
    $exe = $cmd[0]
    $rest = @()
    if ($cmd.Length -gt 1) { $rest = $cmd[1..($cmd.Length - 1)] }
    & $exe @rest
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed: $title (exit $LASTEXITCODE)" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

if (-not (Test-Path 'android/key.properties')) {
    Write-Host ''
    Write-Host 'WARNING: android/key.properties not found.' -ForegroundColor Yellow
    Write-Host 'The build will be signed with DEBUG keys: fine for your own phone,' -ForegroundColor Yellow
    Write-Host 'but Google Play will reject it. See README > Release (Android).' -ForegroundColor Yellow
}

Step 'Cleaning' ($flutter + 'clean')
Step 'Getting packages' ($flutter + @('pub', 'get'))
Step 'Generating strings' ($flutter + 'gen-l10n')
if (-not $SkipChecks) {
    Step 'Analyzing' ($flutter + 'analyze')
    Step 'Running tests' ($flutter + 'test')
}

$common = @('--flavor', 'prod', '--dart-define-from-file=config/prod.json',
    '--obfuscate', '--split-debug-info=build/symbols')
if ($Target -ne 'bundle') { Step 'Building APK' ($flutter + @('build', 'apk') + $common) }
if ($Target -ne 'apk') { Step 'Building App Bundle' ($flutter + @('build', 'appbundle') + $common) }

Write-Host ''
Write-Host 'Done. Outputs:' -ForegroundColor Green
$apk = 'build/app/outputs/flutter-apk/app-prod-release.apk'
$aab = 'build/app/outputs/bundle/prodRelease/app-prod-release.aab'
foreach ($f in @($apk, $aab)) {
    if (Test-Path $f) { Write-Host "  $(Join-Path $root $f)" }
}
Write-Host "  Symbols (keep for crash reports): $(Join-Path $root 'build/symbols')"

if ($Install) {
    if (-not (Test-Path $apk)) { Write-Host 'No APK to install (use -Target apk or both).' -ForegroundColor Red; exit 1 }
    Step 'Installing on phone' ($flutter + @('install', '--flavor', 'prod', '--use-application-binary', $apk))
}
