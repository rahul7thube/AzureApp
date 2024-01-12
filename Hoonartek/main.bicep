metadata description = 'File to deploy web application'
@allowed([
  'dev'
  'test'
  'prod'
  'training'
])
@description('The name of the environment. This must be dev, test, or prod.')
param environmentName string = 'dev'
@description('Size of the Virtual Machine to Provision')
param vmsize string
@description('Generating VM name')
param baseName string = 'hoonartekVM'
var uniqueString = guid(resourceGroup().id, baseName)

@description('Admin user name')
param adminuser string

@description('Should be between 6-72 characters long and a combination of Upper case, lower case, numbers and special chars.')
@secure()
@minLength(6)
param adminpassword string 

@description('Location')
param location string = resourceGroup().location

var appStorageAccountName = 'hoonartek-${environmentName}-${resourceGroup().id}'

resource appStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: appStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}


module hoonartekNetwork 'modules/network.bicep' ={
  name: 'hoonartek-${environmentName}-publicIP'
  params:{
    location:location
  }
}

resource hoonartekApp 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: 'hoonartek-${environmentName}-app'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmsize
    }
    osProfile: {
      computerName: '${baseName}-${substring(uniqueString, 0, 4)}'
      adminUsername: adminuser
      adminPassword: adminpassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-lts'
        version: 'latest'
      }
      osDisk: {
        name: 'app-OSDisk39202191'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: hoonartekNetwork.outputs.networkId
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: appStorageAccount.properties.primaryEndpoints.blob
      }
    }
  }
}

resource appExtension 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  parent: hoonartekApp
  name: 'customScript1'
  location: location
  tags: {
    displayName: 'customScript1 for Linux VM'
  }
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    settings: {
      // Assuming the script is hosted publicly
      fileUris: ['https://github.com/rahul7thube/AzureApp/raw/main/ansible-playbooks/install-playbook.sh']
      commandToExecute: 'bash install-playbook.sh'
    }
  }
}

output application_IP string = hoonartekNetwork.outputs.ipAddress
