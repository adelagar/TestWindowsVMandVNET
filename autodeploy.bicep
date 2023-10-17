@description('Resorce Group location')
param location string = resourceGroup().location

@description('Provide the name of the virtual network')
param vnetName string = 'enter name of the virtual network'

@description('Enter the virtual network prefix')
param vnetPrefix string = 'enter the vnet address prefix'

@description('Enter the ename of the second subnet')
param sNet1 string = 'enter the name of the first subnet'

@description('Enter the address prefix of the first subnet')
param sNet1Prefix string = 'enter the address prefix of first subnet'

@description('Enter the name of the second subnet')
param sNet2 string = 'enter the name of the second subnet'

@description('Enter the address prefix of second subnet')
param sNet2Prefix string = 'enter the address prefix of second subnet prefix'

@description('Enter the name of the third subnet')
param sNet3 string = 'enter the name of the third subnet'

@description('Enter the address prefix of the third subnet')
param sNet3Prefix string = 'enter the address prefix of the third subnet'

@minLength(5)
@maxLength(15)
@description('Enter the name of the virtual machine')
param vmName string = 'name of vm'

@description('Enter the name of the admin account')
param adminName string = 'Enter the name of the admin account'

@description('Enter the password of the admin account')
@minLength(12)
@secure()
param adminPword string = 'Enter the password of the admin account'

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '2016-datacenter'
  '2016-datacenter-gensecond'
  '2016-datacenter-server-core-g2'
  '2016-datacenter-server-core-smalldisk-g2'
  '2016-datacenter-smalldisk-g2'
  '2016-datacenter-with-containers-g2'
  '2016-datacenter-zhcn-g2'
  '2019-datacenter'
  '2019-datacenter-core-g2'
  '2019-datacenter-core-smalldisk-g2'
  '2019-datacenter-core-with-containers-g2'
  '2019-datacenter-core-with-containers-smalldisk-g2'
  '2019-datacenter-gensecond'
  '2019-datacenter-smalldisk-g2'
  '2019-datacenter-with-containers-g2'
  '2019-datacenter-with-containers-smalldisk-g2'
  '2019-datacenter-zhcn-g2'
  '2022-datacenter-azure-edition'
  '2022-datacenter-azure-edition-core'
  '2022-datacenter-azure-edition-core-smalldisk'
  '2022-datacenter-azure-edition-smalldisk'
  '2022-datacenter-core-g2'
  '2022-datacenter-core-smalldisk-g2'
  '2022-datacenter-g2'
  '2022-datacenter-smalldisk-g2'
])
param OSVersion string = '2022-datacenter-azure-edition'

@description('Select the size of the vm in terms of cpu and memory')
@allowed([
  'Standard_DS2_v2'
  'Standard_DS3_v2'
  'Standard_DS4_v2'
  'Standard_DS5_v2'
  'Standard_DS11-1_v2'
  'Standard_DS11_v2'
  'Standard_DS12-1_v2'
  'Standard_DS12-2_v2'
  'Standard_DS12_v2'
  'Standard_DS13-2_v2'
  'Standard_DS13-4_v2'
  'Standard_DS13_v2'

])

param vmSize string = 'Standard_DS3_v2'

@description('Enter the name for the availability set')
param avSet string = 'enter the name of the availability set'

@description('Select the size of the data disk for the server')
@allowed([
  '4'
  '128'
  '512'
  '1023'
  '4096'
  '8192'
  '16384'
  '32767'

])

param dataDiskSize string = '4'

@description('OS disk performance sku')
@allowed([
  'Standard_LRS'
  'Premium_LRS'

])

param osDiskPerformance string = 'Standard_LRS'

@description('Data disk performance sku')
@allowed([
  'Standard_LRS'
  'Premium_LRS'

])

param dataDiskPerformance string = 'Standard_LRS'

var nicName = '${vmName}-NIC'

resource availabilitySet 'Microsoft.Compute/availabilitySets@2020-12-01' = {
  name: '${avSet}'
  location: resourceGroup().location

  properties: {
    'platformFaultDomaincount': 2
    'platformUpdateDomaincount': 3

  }
  sku: {
    name: 'Aligned'
  }
}

resource winNSG 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: '${vmName}-NSG'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'AllowRDPIn'
        properties: {
          description: 'Allow RDP TCP 3389 IN'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: '100'
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowWinRMIn'
        properties: {
          description: 'Allow WinRM TCP 5986 IN'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationPortRange: '5986'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: '110'
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: '${vnetName}'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '${vnetPrefix}'
      ]
    }
    subnets: [
      {
        name: '${sNet1}'
        properties: {
          addressPrefix: '${sNet1Prefix}'

        }
      }
      {
        name: '${sNet2}'
        properties: {
          addressPrefix: '${sNet2Prefix}'
        }
      }
      {
        name: '${sNet3}'
        properties: {
          addressPrefix: '${sNet3Prefix}'

        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: nicName
  location: resourceGroup().location
  properties: {
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${virtualNetwork.id}/subnets/${sNet1}'
          }
        }
      }

    ]
    networkSecurityGroup: {
      id: winNSG.id
    }

  }
}

resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: '${vmName}'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: '${vmSize}'

    }

    availabilitySet: {
      id: availabilitySet.id

    }

    osProfile: {
      computerName: '${vmName}'
      adminUsername: '${adminName}'
      adminPassword: '${adminPword}'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '${OSVersion}'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: '${osDiskPerformance}'
        }

      }
      dataDisks: [
        {
          name: '${vmName}-datadisk'
          diskSizeGB: '${dataDiskSize}'
          lun: 0
          createOption: 'Empty'
          managedDisk: {
            storageAccountType: '${dataDiskPerformance}'
          }
        }

      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id

        }

      ]
    }

  }
}
