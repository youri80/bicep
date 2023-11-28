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

param skuName string = 'S4'

param skuTier string = 'Standard'

param collation string = 'SQL_Latin1_General_CP1_CI_AS'

var sqlServerName = 'sql-${environmentName}-${solutionName}'
var sqlDatabaseNames = [ 'ER' , 'MEW' , 'NEMESYS']


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

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' =[for dbName in sqlDatabaseNames: {
  parent: sqlServer
  name: dbName
  properties: {
    licenseType: 'LicenseIncluded'
    requestedBackupStorageRedundancy: 'Zone'
    collation: collation
  }
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
}]

output SqlserverId string = sqlServer.id
