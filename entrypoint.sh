#!/usr/src/app -l

echo "HI dummy"
echo $PWD
echo $(ls)
chmod +x  ./Orchestration/OrchestrationService/ModuleConfigurationDeployment.ps1
chmod +x ./Environments/SharedServices
./Orchestration/OrchestrationService/ModuleConfigurationDeployment.ps1 -DefinitionPath ./Environments/SharedServices/definition.json