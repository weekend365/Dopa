$ErrorActionPreference = 'Stop'

$repositoryRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$contractPath = Join-Path $repositoryRoot 'config/apple-identifiers.json'
$contract = Get-Content -LiteralPath $contractPath -Raw -Encoding utf8 | ConvertFrom-Json

$expected = @{
    namespace = 'com.devnamu.dopa'
    productionMain = 'com.devnamu.dopa'
    productionGroup = 'group.com.devnamu.dopa'
    productionMonitor = 'com.devnamu.dopa.activitymonitor'
    productionReport = 'com.devnamu.dopa.activityreport'
    productionShieldConfiguration = 'com.devnamu.dopa.shieldconfiguration'
    productionShieldAction = 'com.devnamu.dopa.shieldaction'
    developmentMain = 'com.devnamu.dopa.dev'
    developmentGroup = 'group.com.devnamu.dopa.dev'
    developmentMonitor = 'com.devnamu.dopa.dev.activitymonitor'
    developmentReport = 'com.devnamu.dopa.dev.activityreport'
    developmentShieldConfiguration = 'com.devnamu.dopa.dev.shieldconfiguration'
    developmentShieldAction = 'com.devnamu.dopa.dev.shieldaction'
    monthlyProduct = 'com.devnamu.dopa.plus.monthly'
    annualProduct = 'com.devnamu.dopa.plus.annual'
}

function Assert-Equal {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)]$Actual,
        [Parameter(Mandatory = $true)]$Expected
    )

    if ($Actual -ne $Expected) {
        throw "$Name mismatch. Expected '$Expected', got '$Actual'."
    }
}

Assert-Equal -Name 'namespace' -Actual $contract.namespace -Expected $expected.namespace
Assert-Equal -Name 'production.mainApp' -Actual $contract.production.mainApp -Expected $expected.productionMain
Assert-Equal -Name 'production.appGroup' -Actual $contract.production.appGroup -Expected $expected.productionGroup
Assert-Equal -Name 'production.extensions.deviceActivityMonitor' -Actual $contract.production.extensions.deviceActivityMonitor -Expected $expected.productionMonitor
Assert-Equal -Name 'production.extensions.deviceActivityReport' -Actual $contract.production.extensions.deviceActivityReport -Expected $expected.productionReport
Assert-Equal -Name 'production.extensions.shieldConfiguration' -Actual $contract.production.extensions.shieldConfiguration -Expected $expected.productionShieldConfiguration
Assert-Equal -Name 'production.extensions.shieldAction' -Actual $contract.production.extensions.shieldAction -Expected $expected.productionShieldAction
Assert-Equal -Name 'development.mainApp' -Actual $contract.development.mainApp -Expected $expected.developmentMain
Assert-Equal -Name 'development.appGroup' -Actual $contract.development.appGroup -Expected $expected.developmentGroup
Assert-Equal -Name 'development.extensions.deviceActivityMonitor' -Actual $contract.development.extensions.deviceActivityMonitor -Expected $expected.developmentMonitor
Assert-Equal -Name 'development.extensions.deviceActivityReport' -Actual $contract.development.extensions.deviceActivityReport -Expected $expected.developmentReport
Assert-Equal -Name 'development.extensions.shieldConfiguration' -Actual $contract.development.extensions.shieldConfiguration -Expected $expected.developmentShieldConfiguration
Assert-Equal -Name 'development.extensions.shieldAction' -Actual $contract.development.extensions.shieldAction -Expected $expected.developmentShieldAction
Assert-Equal -Name 'subscriptions.monthlyProductId' -Actual $contract.subscriptions.monthlyProductId -Expected $expected.monthlyProduct
Assert-Equal -Name 'subscriptions.annualProductId' -Actual $contract.subscriptions.annualProductId -Expected $expected.annualProduct
Assert-Equal -Name 'subscriptions.trialDays' -Actual $contract.subscriptions.trialDays -Expected 7
Assert-Equal -Name 'subscriptions.monthlyPriceKrw' -Actual $contract.subscriptions.monthlyPriceKrw -Expected 5900
Assert-Equal -Name 'subscriptions.annualPriceKrw' -Actual $contract.subscriptions.annualPriceKrw -Expected 39000

$allIdentifiers = @(
    $contract.production.mainApp
    $contract.production.extensions.deviceActivityMonitor
    $contract.production.extensions.deviceActivityReport
    $contract.production.extensions.shieldConfiguration
    $contract.production.extensions.shieldAction
    $contract.development.mainApp
    $contract.development.extensions.deviceActivityMonitor
    $contract.development.extensions.deviceActivityReport
    $contract.development.extensions.shieldConfiguration
    $contract.development.extensions.shieldAction
)

if (($allIdentifiers | Select-Object -Unique).Count -ne $allIdentifiers.Count) {
    throw 'Apple app and extension identifiers must be unique.'
}

foreach ($identifier in $allIdentifiers) {
    if ($identifier -cnotmatch '^[a-z0-9]+(\.[a-z0-9]+)+$') {
        throw "Invalid lowercase reverse-DNS identifier: '$identifier'."
    }
}

foreach ($property in $contract.production.extensions.PSObject.Properties) {
    if (-not $property.Value.StartsWith("$($contract.production.mainApp).")) {
        throw "Production extension '$($property.Name)' must be prefixed by the production app identifier."
    }
}

foreach ($property in $contract.development.extensions.PSObject.Properties) {
    if (-not $property.Value.StartsWith("$($contract.development.mainApp).")) {
        throw "Development extension '$($property.Name)' must be prefixed by the development app identifier."
    }
}

Write-Output 'Apple identifier contract is valid.'
