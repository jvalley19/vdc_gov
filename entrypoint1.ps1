#!/usr/src/app
$null = Find-Module -Name Az | Install-Module -Force
$null = Install-Module Az.ResourceGraph -Force
$null = Install-Module -Name Az.Accounts -Force
$null = Install-Module -Name Pester -Force

$secpasswd = ConvertTo-SecureString $env:SERVICE_PRINCIPAL_PASS -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($env:SERVICE_PRINCIPAL, $secpasswd)

Add-AzAccount -ServicePrincipal -Credential $Credential -Tenant $env:TENANT_ID

#set -x
Write-Host "HI dummy"
Write-Debug Get-Location 
#Write-Debug $(ls)
##chmod +x ./Environments/SharedServices
$DebugPreference="Continue"
./Orchestration/OrchestrationService/ModuleConfigurationDeployment.ps1 -DefinitionPath ./Environments/SharedServices/definition.json