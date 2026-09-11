param([switch]$PromptForKey, [switch]$Doppler, [switch]$RequireKey)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path $PSScriptRoot -Parent
if ($Doppler) {
    if ($PromptForKey) { throw 'Use tooling/set_diary_key.ps1 to save the key to Doppler first.' }
    $dopplerExe = (Get-Command doppler.exe -ErrorAction Stop).Source
    & $dopplerExe run --project dopa --config dev --no-fallback --no-check-version --only-secrets OPENAI_API_KEY -- powershell.exe -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -RequireKey
    if ($LASTEXITCODE -ne 0) { throw 'Doppler startup failed. Save OPENAI_API_KEY in dopa/dev first. The existing server was not stopped if secret loading failed.' }
    exit 0
}
if ($RequireKey -and $env:OPENAI_API_KEY -cnotmatch '^sk-\S{20,}$') {
    throw 'OPENAI_API_KEY has an invalid format. Save the full key with tooling/set_diary_key.ps1. The existing server was not stopped.'
}
$serverFile = [IO.Path]::GetFullPath((Join-Path $taskRoot 'backend/diary/src/server.mjs'))
$stateDir = Join-Path $taskRoot '.tooling'
$pidFile = Join-Path $stateDir 'diary-server.pid'
New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
if ($PromptForKey) {
    . (Join-Path $PSScriptRoot 'read_diary_key.ps1')
    $enteredKey = Read-DiaryApiKey
}
if (Test-Path -LiteralPath $pidFile) {
    $serverProcessId = [int](Get-Content -LiteralPath $pidFile)
    $candidate = Get-CimInstance Win32_Process -Filter "ProcessId = $serverProcessId"
    if ($candidate -and $candidate.Name -eq 'node.exe' -and $candidate.CommandLine.Contains($serverFile)) {
        Stop-Process -Id $serverProcessId
    } elseif ($candidate) {
        throw 'The saved PID belongs to another process. It was not stopped.'
    }
}
$previousKey = $env:OPENAI_API_KEY
try {
    if ($PromptForKey) {
        $env:OPENAI_API_KEY = $enteredKey
    }
    $serverProcess = Start-Process -FilePath (Get-Command node.exe).Source `
        -ArgumentList @('"' + $serverFile + '"') -WorkingDirectory (Split-Path $serverFile -Parent) `
        -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput (Join-Path $stateDir 'diary-server.log') `
        -RedirectStandardError (Join-Path $stateDir 'diary-server-error.log')
    Set-Content -LiteralPath $pidFile -Value $serverProcess.Id
} finally {
    $env:OPENAI_API_KEY = $previousKey
    $enteredKey = $null
}
Start-Sleep -Milliseconds 700
$health = Invoke-RestMethod 'http://127.0.0.1:8787/v1/health'
Write-Output ('Dopa diary server running. Image API configured: ' + $health.enabled)
$adb = Join-Path $taskRoot '.tooling/android-sdk/platform-tools/adb.exe'
if (Test-Path -LiteralPath $adb) {
    & $adb -s emulator-5554 reverse tcp:8787 tcp:8787
}
