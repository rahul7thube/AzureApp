@allowed([
  'dev'
  'test'
  'prod'
])
@description('The name of the environment. This must be dev, test, or prod.')
param environmentName string = 'dev'
param location string = resourceGroup().location

resource hoonartekNetworkIP 'Microsoft.Network/publicIPAddresses@2023-06-01' ={
  name: 'hoonartek-${environmentName}-publicIP'
  location: location
  properties:{
    publicIPAllocationMethod: 'Static'
  }
}

resource hoonartekNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'hoonartek-${environmentName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'apache2'
        properties: {
          description: 'Allow HTTP Access'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['80','5432']
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'SSH'
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
        name: 'tomcat'
        properties: {
          description: 'Allow HTTP Access'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: '8080'
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


resource hoonartekVirtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'hoonartek-${environmentName}-vn'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'hoonartek-${environmentName}-subnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: hoonartekNetworkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource hoonartekNetworkInterface 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: 'hoonartek-${environmentName}-NIF'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: hoonartekNetworkIP.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'hoonartek-${environmentName}-vn', 'hoonartek-${environmentName}-subnet')
          }
        }
      }
    ]
  }
  dependsOn: [

    hoonartekVirtualNetwork
  ]
}
output networkId string = hoonartekNetworkInterface.id
output ipAddress string = hoonartekNetworkIP.properties.ipAddress
