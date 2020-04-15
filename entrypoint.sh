#!/bin/bash -l

echo "HI dummy"

chmod +x  ./Orchestration/OrchestrationService/ModuleConfigurationDeployment.ps1

./Orchestration/OrchestrationService/ModuleConfigurationDeployment.ps1 -DefinitionPath ./Environments/SharedServices/definition.json