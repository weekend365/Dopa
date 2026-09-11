$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$assetDirectory = Join-Path $repositoryRoot 'apps/mobile/assets/garden'
$combinedBytes = 0
foreach ($theme in @('light','dark')) {
    foreach ($stage in 0..7) {
        $assetPath = Join-Path $assetDirectory ("${theme}_${stage}.webp")
        $bytes = [System.IO.File]::ReadAllBytes($assetPath)
        if ([System.Text.Encoding]::ASCII.GetString($bytes,0,4) -ne 'RIFF' -or
            [System.Text.Encoding]::ASCII.GetString($bytes,8,4) -ne 'WEBP') { throw "Invalid WebP: $assetPath" }
        $combinedBytes += $bytes.Length
    }
}
if ((Get-ChildItem -LiteralPath $assetDirectory -Filter '*.webp').Count -ne 16) { throw 'Expected 16 landscapes' }
if ($combinedBytes -gt 6*1024*1024) { throw 'Garden artwork exceeds 6MiB' }
Write-Output "Garden assets: 16 WebP images, $combinedBytes bytes. Flutter asset contract test verifies decoded 1152x768 dimensions."
