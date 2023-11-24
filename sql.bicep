@description('The name of the environment. This must be dev, test, or prod.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'dev'

@description('The unique name of the solution. This is used to ensure that resource names are unique.')
@minLength(5)
@maxLength(30)
param solutionName string = 'tis-${uniqueString(resourceGroup().id)}'

param vnetname  string = 'vnet-ertragsrechnung-dev-01'
param networkResourceGroup string = 'rg-ertragchsrechnung-dev-networking'

var subnetID = resourceId(networkResourceGroup,'Microsof.Network/virtualNetwork',vnetname )

/*@description('The name and tier of the App Service plan SKU.')
param appServicePlanSku object
*/
@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorPassword string


var privateEndpointName = 'pv-tis-${environmentName}-${solutionName}'


var sqlServerName = 'sql-${environmentName}-${solutionName}'
var sqlDatabaseNames = [ 'ER' , 'MEW']
var sqlNicName = 'nic-sql-${environmentName}-${solutionName}'

resource tisVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name : vnetname
  scope: resourceGroup(networkResourceGroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: '/subnet1'
  scope: resourceGroup(networkResourceGroup)
}


resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
  }

}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: privateEndpointName
  location: location
  properties:{
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
    subnet: {
      id: subnet.id
    } 
    
  }
  
}




resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' =[for dbName in sqlDatabaseNames: {
  parent: sqlServer
  name: dbName
  properties: {
    licenseType: 'LicenseIncluded'
    requestedBackupStorageRedundancy: 'Zone'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
  location: location
  sku: {
    name: 'S4'
    tier: 'Standard'
  }
}]
