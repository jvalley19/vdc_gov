#!/usr/src/app

#set -x
Write-Host "HI dummy"
Write-Host "$PATH" 
Write-Debug $(ls)
##chmod +x ./Environments/SharedServices
./Orchestration/OrchestrationService/ModuleConfigurationDeployment.ps1 -DefinitionPath ./Environments/SharedServices/definition.json