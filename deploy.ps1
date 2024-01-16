param([Parameter(Mandatory)]$resourceGroup, $subscription)

$s = ''
if ([string]::IsNullOrEmpty($subscription)) {
    $s = az account show --query "id" --output tsv
} else {
    $s = $subscription
}
Write-Host "Using subscription $s"

Write-Host "Deploying main.bicep"
az deployment group create --resource-group $resourceGroup --subscription $s --template-file .\main.bicep --parameters .\main.bicepparam

Write-Host "Retrieving function name"
$lastDeployment = az deployment group list --resource-group $resourceGroup --query "[0].name" --output tsv --subscription $s
$deploymentOutput = az deployment group show --resource-group $resourceGroup --name $lastDeployment --query "properties.outputs" --output json --subscription $s | ConvertFrom-Json
$functionName = $deploymentOutput.funcName.value

Write-Host "Deploying function $functionName"
try
{
    $currDir = Get-Location
    Set-Location -Path .\src\JuulHobert.Blog.FunctionAppWithAppConfig
    dotnet publish -c Release

    $projectPath = Get-Location
    $publishOutputPath = Join-Path $projectPath "bin\Release\net6.0\publish\*"
    $zipFilePath = Join-Path $projectPath "functionapp.zip"
    Compress-Archive -Path $publishOutputPath -DestinationPath $zipFilePath -Force

    az functionapp deployment source config-zip --resource-group $resourceGroup --subscription $s --name $functionName --src $zipFilePath

    Remove-Item $zipFilePath
} finally {
    Set-Location -Path $currDir
}
