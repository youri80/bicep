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
param networkResourceGroup string = 'rg-ertragsrechnung-dev-networking'

@description('Id of SqlServer to connect to Vnet')
param sqlServerid string = ''

param sqlSubnetName string = 'subnet1'


/*@description('The name and tier of the App Service plan SKU.')
param appServicePlanSku object
*/
@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

//Name of private endpoint
var privateEndpointName = 'pv-sql-${environmentName}-${solutionName}'

resource tisVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name : vnetname
  scope: resourceGroup(networkResourceGroup)
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: privateEndpointName
  location: location
  properties:{
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: sqlServerid
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
    subnet: {
      id: filter(tisVnet.properties.subnets, s => s.name == sqlSubnetName)[0].id
    } 
    
  }
}



