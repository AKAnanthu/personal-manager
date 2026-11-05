# Clean, fetch packages and run the app in one go.
#
#   .\run.cmd                      dev build on the connected phone
#   .\run.cmd -Flavor prod         prod flavor (debug mode)
#   .\run.cmd -Device RZ8T8061YFD  pick a device when several are connected
#   .\run.cmd -Release             run in release mode (fast, no hot reload)
#   .\run.cmd -NoClean             skip "flutter clean" (much quicker)
#   .\run.cmd -Codegen             also regenerate drift code (after table edits)
param(
    [ValidateSet('dev', 'prod')] [string] $Flavor = 'dev',
    [string] $Device = '',
    [switch] $Release,
    [switch] $NoClean,
    [switch] $Codegen
)

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

# Use the project's pinned Flutter (FVM) when available.
if (Get-Command fvm -ErrorAction SilentlyContinue) {
    $flutter = @('fvm', 'flutter'); $dart = @('fvm', 'dart')
} else {
    $flutter = @('flutter'); $dart = @('dart')
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

if (-not $NoClean) { Step 'Cleaning' ($flutter + 'clean') }
Step 'Getting packages' ($flutter + @('pub', 'get'))
Step 'Generating strings' ($flutter + 'gen-l10n')
if ($Codegen) {
    Step 'Generating database code' ($dart + @('run', 'build_runner', 'build', '--delete-conflicting-outputs'))
}

$runArgs = @('run', '--flavor', $Flavor, "--dart-define-from-file=config/$Flavor.json")
if ($Release) { $runArgs += '--release' }
if ($Device) { $runArgs += @('-d', $Device) }
Step "Running ($Flavor$(if ($Release) { ', release' }))" ($flutter + $runArgs)
