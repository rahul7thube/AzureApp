metadata description = 'File to deploy web application'
@description('Size of the Virtual Machine to Provision')
param vmsize string

@description('Admin user name')
param adminuser string

@description('Should be between 6-72 characters long and a combination of Upper case, lower case, numbers and special chars.')
@secure()
param adminpassword string

@description('Location')
param location string

resource appstorage39202192 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: toLower('appstorage39202192')
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}

resource application_IP 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: 'application-IP'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource app_nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'app-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow_HTTP'
        properties: {
          description: 'Allow HTTP Access'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_SSH'
        properties: {
          description: 'Allow SSH Access'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 101
          direction: 'Inbound'
        }
      }
      {
        name: 'postgresql_port'
        properties: {
          description: 'Allow DB Access'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '5432'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 102
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource app_vn 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'app-vn'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'app-subnet1'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: app_nsg.id
          }
        }
      }
    ]
  }
}

resource app_nic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: 'app-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: application_IP.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'app-vn', 'app-subnet1')
          }
        }
      }
    ]
  }
  dependsOn: [

    app_vn
  ]
}

resource app 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: 'app'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmsize
    }
    osProfile: {
      computerName: 'app'
      adminUsername: adminuser
      adminPassword: adminpassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '22_04-lts'
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
          id: app_nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: appstorage39202192.properties.primaryEndpoints.blob
      }
    }
  }
}
resource appExtension 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  parent: app
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

/*resource app_customScript1 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  parent: app
  name: 'customScript1'
  location: location
  tags: {
    displayName: 'customScript1 for Linux VM'
  }
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://github.com/gopi-s-ht/EchoApplication/raw/main/web_server_init.sh'
      ]
    }
    protectedSettings: {
      commandToExecute: 'sh web_server_init.sh'
    }
  }
}*/

output application_IP string = application_IP.properties.ipAddress
