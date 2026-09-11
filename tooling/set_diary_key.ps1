$ErrorActionPreference = 'Stop'
$dopplerExe = (Get-Command doppler.exe -ErrorAction Stop).Source
. (Join-Path $PSScriptRoot 'read_diary_key.ps1')
$keyValue = Read-DiaryApiKey
# Pass the key through stdin, never through command arguments or temporary files.
# Suppress both output streams because the CLI may include secret values.
$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = $dopplerExe
$startInfo.Arguments = 'secrets set OPENAI_API_KEY --project dopa --config dev --visibility masked --no-interactive --no-check-version'
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true
$startInfo.RedirectStandardInput = $true
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true
$process = New-Object System.Diagnostics.Process
$process.StartInfo = $startInfo
try {
    [void]$process.Start()
    $stdoutDrain = $process.StandardOutput.BaseStream.CopyToAsync([IO.Stream]::Null)
    $stderrDrain = $process.StandardError.BaseStream.CopyToAsync([IO.Stream]::Null)
    $process.StandardInput.Write($keyValue)
    $process.StandardInput.Close()
    $process.WaitForExit()
    $stdoutDrain.GetAwaiter().GetResult()
    $stderrDrain.GetAwaiter().GetResult()
    if ($process.ExitCode -ne 0) { throw 'Doppler save failed. Check Doppler login and project permissions.' }
    Write-Output 'OPENAI_API_KEY saved to Doppler dopa/dev. Restart with start_diary_server.ps1 -Doppler.'
} finally {
    $keyValue = $null
    $process.Dispose()
}
