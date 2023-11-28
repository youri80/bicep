//Environment
@description('The name of the environment. This must be dev, test, or prod.')
@allowed([
  'dev'
  'test'
  'prod'
])

param environmentName string = 'dev'

//SqlServer
@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorPassword string



//Network for Sql
@description('Subnet name for Sql Server')
param subnetSqlServer string = 'subnet1'

@description('Subnet name for App Instance')
param subnetApp string = 'subnet2'

@description('Name of virtual network')
param networkResourceGroup string = 'rg-ertragsrechnung-dev-networking'

@description('Name of resource group virtual network')
param vnetname  string = 'vnet-ertragsrechnung-dev-01'

param solutionName string = 'tis-${uniqueString(resourceGroup().id)}'

param location string = resourceGroup().location

module sqlServer 'sql.bicep' = {
  name: 'sqlServerModul'
   params: {
    location: location
    sqlServerAdministratorLogin: sqlServerAdministratorLogin
    sqlServerAdministratorPassword: sqlServerAdministratorPassword
   } 
}

module network 'sql_network.bicep' = {
  name : 'networkModul'
  params: {
      sqlServerid: sqlServer.outputs.SqlserverId
      environmentName: environmentName
      networkResourceGroup: networkResourceGroup
      vnetname:vnetname
      location: location
      sqlSubnetName: subnetSqlServer
      solutionName: solutionName
  }
  dependsOn: [
    sqlServer
  ]
}
