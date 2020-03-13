# **To deploy Azure Virtual Datacenter for VDI**

Deployment steps for [MS-VDI](../../Environments/MS-VDI) archetypes provided in the toolkit.

## Prerequisites

For some resources the deployment works only from Docker containers. 
* [Docker](https://www.docker.com/get-started)
* [Git](https://git-scm.com/downloads)
* [Visual Studio Code](https://code.visualstudio.com/) or any text editor

You can install these on your local machine or you can use the lab VM provided in the toolkit.
See these instructions for [setting up the lab VM](../LabVM/README.md).

After these prerequisties are installed, [clone the reposistory on GitHub](https://help.github.com/en/articles/cloning-a-repository-from-github) and [build a Docker image](https://docs.docker.com/glossary/?term=build).
This quickstart assumes that you will be interacting with the toolkit through the Docker image.

### Clone the repository

These steps assume that the `git` command is on your path.

1. Open a terminal window
1. Navigate to a folder where you want to store the source for the toolkit. If you are using the labVM, you can use the default `c:\Users\vdcadmin` folder.
1. Run `git clone https://github.com/Azure/vdc.git`. This will clone the GitHub repository in a folder named `vdc`.
1. Run `cd vdc` to change directory in the source folder.
1. Run `git checkout master` to switch to the branch with the current in-development version of the toolkit.

### Build the Docker image

1. Ensure that the [Docker daemon](https://docs.docker.com/config/daemon/) is running. If you are new to Docker, the easiest way to do this is to install [Docker Desktop](https://www.docker.com/products/docker-desktop).
1. Open a terminal window
1. Navigate to the folder where you cloned the repository. _The rest of the quickstart assumes that this path is `C:\Users\vdcadmin\vdc\`_
1. Run `docker build . -t vdc:latest` to build the image.

### Run the toolkit container
After the image finishing building, you can run it using:

`docker run -it --rm -v C:\Users\vdcadmin\vdc\Config:/usr/src/app/Config -v C:\Users\vdcadmin\vdc\Environments:/usr/src/app/Environments -v C:\Users\vdcadmin\vdc\Modules:/usr/src/app/Modules vdc:latest`

A few things to note:
- You don't need to build the image every time you want to run the container. You'll only need to rebuild it if there are changes to the source (primarily changes in the `Orchestration` folder).
- The `docker run` command above will map volumes in the container to volumes on the host machine. This will allow you to directly modify files in these directories (`Config`,`Environments`, and `Modules`).

When the container starts, you will see the prompt
`PS /usr/src/app>`

## Configure the toolkit

To configure the toolkit for this quickstart, we will need to collect the following information.

You'll need:
- A subscription for the toolkit to use for logging and tracking deployment.
- The associated tenant id of the Azure Active Directory associated with those subscriptions.
- The object id of the user account that you'll use to run the deployment.
- The object id of a [service principal](https://docs.microsoft.com/azure/active-directory/develop/howto-create-service-principal-portal) that Azure DevOps can use for deployment.
- An organization name for generating a prefix for naming resources.
- The desired username and password for the Active Directory domain admin that will be created. Active Directory is not deployed now.
- The desired password of the Windows jumpbox.

Note: You can use a single subscription. You'll just need to provide the same subscription id in multiple locations in the configuration.

### Collecting user object id and tentant id

You can get your user object id and tenant id in the portal or by using command line utitilies.

Using Azure PowerShell:

1. Run `Connect-AzAccount -Tenant "[TENANT_ID]" -SubscriptionId "[SUBSCRIPTION_ID]" -EnvironmentName "[AZURE_ENVIRONMENT]"` to login and set an Azure context.
1. Run `Get-AzContext | % { Get-AzADUser -UserPrincipalName $($_.Account.Id) } | select Id` to get the user object id.
1. Run `Get-AzContext | select Tenant` to get the tenant id.

### Setting the configuration

To deploy the MS-VDI environment, you will need to modify two configuration files and set several environmental variables.

#### [`Config\toolkit.subscription.json`](../Config/toolkit.subscription.json)

This file is for toolkit configuration in general.

- Set `Subscription.TenantId` to the tenant id note above.
- Set `Subscription.SubscriptionId` to the id of the subscription used for logging and deployment state tracking noted above.

#### [`Environments\_Common\subscriptions.json`](../Environments/_Common/subscriptions.json)

This file is for the deployment enviroments configuration. In the quickstart, we are only interested in the `MS-VDI`.

- Set `MS-VDI.TenantId` to the tenant id note above.
- Set `MS-VDI.SubscriptionId` to the id of the target subscription for the deployment noted above.

#### Environmental variables

The toolkit uses environmental variables instead of configuration files to help avoid the accidental inclusion of secrets into your source control. In the context of a CI/CD pipeline, these values would be retrieved from a key vault.

You can set these environmental variables by substituting the actual values in the script below.
You can then copy and paste this script into PowerShell to execute it.

Note: The first two variables are set with the content of the configuration files we just modified. The path will not resolve correctly unless you are in `/usr/src/app` directory. 

```PowerShell
$ENV:VDC_SUBSCRIPTIONS = (Get-Content .\Environments\_Common\subscriptions.json -Raw)
$ENV:VDC_TOOLKIT_SUBSCRIPTION = (Get-Content .\Config\toolkit.subscription.json -Raw)
$ENV:ORGANIZATION_NAME = "MS"
$ENV:AZURE_LOCATION = "[AZURE_REGION]"
$ENV:AzureEnvironmentName ="[AZURE_ENVIRONMENT]"
$ENV:TENANT_ID = "[TENANT_ID]"
$ENV:SUBSCRIPTION_ID = "[SUBSCRIPTION_ID]"
$ENV:KEYVAULT_MANAGEMENT_USER_ID  = "[KEY_VAULT_MANAGEMENT_USER_ID]"
$ENV:DEVOPS_SERVICE_PRINCIPAL_USER_ID = "[SERVICE_PRINCIPAL_USER_ID]"
$ENV:DOMAIN_ADMIN_USERNAME = "[DOMAIN_ADMIN_USER_NAME]"
$ENV:DOMAIN_ADMIN_USER_PWD = "[DOMAIM_ADMIN_USER_PASSWORD]"
$ENV:ADMIN_USER_NAME = "[VM_ADMIN_USER_NAME]"
$ENV:ADMIN_USER_PWD = "[VM_ADMIN_USER_PASSWORD]"
```

To use the above script:

1. Return to the running Docker container from earlier in the quickstart.
2. Confirm that you are in the `/usr/src/app` directory.
3. Make a copy of the above script and replace the necessary values.
4. Copy the script into the clipboard and paste it in the terminal.
5. Verify that the enviromental variables are set by running `env` to view the current values.

#### Parameters
Any application specific parameters updates should be done in the [parameters.json](../../Environments/MS-VDI/parameters.json) file such as IP address, subnet names, subnet range, secrets etc.

## Deploying the MS-VDI environment

1. Return to the running Docker container from earlier in the quickstart.
1. If you have not already done so, run `Connect-AzAccount -Tenant "[TENANT_ID]" -SubscriptionId "[SUBSCRIPTION_ID]" -EnvironmentName "[AZURE_ENVIRONMENT]"` to login and set an Azure context.
1. To deploy the entire MS-VDI environment, you can run a single command:

    ``` PowerShell
    ./Orchestration/OrchestrationService/ModuleConfigurationDeployment.ps1 -DefinitionPath ./Environments/MS-VDI/definition.json
    ```

The toolkit will begin deploying the constituent modules and the status will be sent to the terminal.
Open the [Azure portal](https://portal.azure.us) and you can check the status of the invididual deployments. Azure portal link will be based on azure environment.

## Deploying individual modules

If you prefer you can deploy the constituent modules for MS-VDI individually.
The following is the series of commands to execute.

``` PowerShell
        .\Orchestration\OrchestrationService\ModuleConfigurationDeployment.ps1 -DefinitionPath .\Environments\MS-VDI\definition.json -ModuleConfigurationName "VirtualNetworkHUB"
        .\Orchestration\OrchestrationService\ModuleConfigurationDeployment.ps1 -DefinitionPath .\Environments\MS-VDI\definition.json -ModuleConfigurationName "VirtualNetworkSPOKE"
        .\Orchestration\OrchestrationService\ModuleConfigurationDeployment.ps1 -DefinitionPath .\Environments\MS-VDI\definition.json -ModuleConfigurationName "VirtualNetworkPeeringHub"
        .\Orchestration\OrchestrationService\ModuleConfigurationDeployment.ps1 -DefinitionPath .\Environments\MS-VDI\definition.json -ModuleConfigurationName "VirtualNetworkPeeringSpoke"
        .\Orchestration\OrchestrationService\ModuleConfigurationDeployment.ps1 -DefinitionPath .\Environments\MS-VDI\definition.json -ModuleConfigurationName "DiagnosticStorageAccount"
        .\Orchestration\OrchestrationService\ModuleConfigurationDeployment.ps1 -DefinitionPath .\Environments\MS-VDI\definition.json -ModuleConfigurationName "EnableServiceEndpointOnDiagnosticStorageAccount"
        .\Orchestration\OrchestrationService\ModuleConfigurationDeployment.ps1 -DefinitionPath .\Environments\MS-VDI\definition.json -ModuleConfigurationName "LogAnalytics"
        .\Orchestration\OrchestrationService\ModuleConfigurationDeployment.ps1 -DefinitionPath .\Environments\MS-VDI\definition.json -ModuleConfigurationName "KeyVault"
        .\Orchestration\OrchestrationService\ModuleConfigurationDeployment.ps1 -DefinitionPath .\Environments\MS-VDI\definition.json -ModuleConfigurationName "ArtifactsStorageAccount"
        .\Orchestration\OrchestrationService\ModuleConfigurationDeployment.ps1 -DefinitionPath .\Environments\MS-VDI\definition.json -ModuleConfigurationName "UploadScriptsToArtifactsStorage"
        .\Orchestration\OrchestrationService\ModuleConfigurationDeployment.ps1 -DefinitionPath .\Environments\MS-VDI\definition.json -ModuleConfigurationName "JumpboxASG"
        .\Orchestration\OrchestrationService\ModuleConfigurationDeployment.ps1 -DefinitionPath .\Environments\MS-VDI\definition.json -ModuleConfigurationName "WindowsVM"
```

**NOTE: **
1. If deployment reports, unable to find deployment storage account, it could be that PowerShell is not connected to Azure.
2. Open a new PowerShell/Docker instance if there was any changes to files in Environments folder

### **Teardown the environment**
**Note:** Have not tested yet!

``` PowerShell
./Orchestration/OrchestrationService/ModuleConfigurationDeployment.ps1 -TearDownEnvironment -DefinitionPath ./Environments/MS-VDI/definition.json
```

Note: This is the same command you used to deploy except that you include ` -TearDownEnvironment`.
It uses the same configuration, so if you change the configuration the tear down may not execute as expected.

For safety reasons, the key vault will not be deleted. Instead, it will be set to a _removed_ state. This means that the name is still considered in use. To fully delete the key vault, use:

``` PowerShell
Get-AzKeyVault -InRemovedState | ? { Write-Host "Removing vault: $($_.VaultName)"; Remove-AzKeyVault -InRemovedState -VaultName $_.VaultName -Location $_.Location -Force }
```
