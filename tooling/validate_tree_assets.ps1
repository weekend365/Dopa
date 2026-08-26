$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$assetDirectory = Join-Path $repositoryRoot 'apps/mobile/assets/tree'
$assetNames = @(
    'zelkova_growth_sprite_light.png',
    'zelkova_growth_sprite_dark.png'
)

$expectedWidth = 1536
$expectedHeight = 1024
$maximumCombinedBytes = 6 * 1024 * 1024
$combinedBytes = 0

function Read-BigEndianInt32 {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]] $Bytes,
        [Parameter(Mandatory = $true)]
        [int] $Offset
    )

    return (([int] $Bytes[$Offset] * 16777216) +
        ([int] $Bytes[$Offset + 1] * 65536) +
        ([int] $Bytes[$Offset + 2] * 256) +
        [int] $Bytes[$Offset + 3])
}

foreach ($assetName in $assetNames) {
    $assetPath = Join-Path $assetDirectory $assetName
    if (-not (Test-Path -LiteralPath $assetPath -PathType Leaf)) {
        throw "Missing tree fallback asset: $assetPath"
    }

    $bytes = [System.IO.File]::ReadAllBytes($assetPath)
    if ($bytes.Length -lt 24) {
        throw "Tree fallback asset is too small to be a PNG: $assetPath"
    }

    $pngSignature = @(137, 80, 78, 71, 13, 10, 26, 10)
    for ($index = 0; $index -lt $pngSignature.Length; $index += 1) {
        if ($bytes[$index] -ne $pngSignature[$index]) {
            throw "Tree fallback asset has an invalid PNG signature: $assetPath"
        }
    }

    $width = Read-BigEndianInt32 -Bytes $bytes -Offset 16
    $height = Read-BigEndianInt32 -Bytes $bytes -Offset 20
    if ($width -ne $expectedWidth -or $height -ne $expectedHeight) {
        throw "Unexpected tree sprite dimensions for ${assetName}: ${width}x${height}"
    }

    # IHDR color type 2 is truecolor RGB with no alpha channel. The fallback
    # contract intentionally uses opaque theme-matched canvases.
    $colorType = [int] $bytes[25]
    if ($colorType -ne 2) {
        throw "Tree fallback asset must be opaque RGB (PNG color type 2): ${assetName} uses ${colorType}"
    }

}

# Count every shipped tree binary, not only the mandatory fallback sprites, so
# a future .riv or local texture cannot silently exceed the complete 6 MiB
# runtime budget. Documentation files are intentionally excluded.
$treeBinaryAssets = Get-ChildItem -LiteralPath $assetDirectory -File |
    Where-Object { $_.Extension -notin @('.md', '.txt') }
foreach ($treeBinaryAsset in $treeBinaryAssets) {
    $combinedBytes += $treeBinaryAsset.Length
}

if ($combinedBytes -gt $maximumCombinedBytes) {
    throw "Tree runtime assets exceed 6 MiB: $combinedBytes bytes"
}

Write-Output "Tree runtime assets valid: $combinedBytes bytes total."
