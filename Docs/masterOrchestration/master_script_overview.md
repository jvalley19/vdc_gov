The master orchestration script is used to deploy multiple environments by executing only one script in the PowerShell 7 command prompt.

Two environment types exisit with v1 of the master orchestration script
- "Shared Services" - located [SharedServices](../../Environments/SharedServices)
- "MS-VDI" - located [MS-VDI](../../Environments/MS-VDI)

The topology for the VDC toolkit is a hub and spoke model. The "shared services" environment(s) act as the hub and the "ms-vdi" environment(s) act as the 
spokes. 

The "Shared Services" environment can be broken down into multiple "shared service" environments if necessary. For example, if an organization wanted to split up the 
Active Directory components into a separate VNET and peer to the hub that can be done with the master orchestration script. 
Note: For testing purposes we suggest using one hub to begin and multiple spokes

The "MS-VDI" environment can be replicated 'X' number of times for the orchestration. Each spoke MS-VDI environment will be peered to the "Shared Services" or HUB environment.
Refer to the [folder_Replication](../MasterOrchestration/folder_replication.md) for more information on how to create multiple spoke "MS-VDI" environments.

