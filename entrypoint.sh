#!/bin/bash -l

echo "HI dummy"

chmod +x  ./Orchestration/OrchestrationService/ModuleConfigurationDeployment.ps1
chmod +x ./Environments/SharedServices
./Orchestration/OrchestrationService/ModuleConfigurationDeployment.ps1 -DefinitionPath ./Environments/SharedServices/definition.json