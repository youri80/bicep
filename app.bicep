param location string = resourceGroup().location

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


var tisAppGui = 'gui-${environmentName}-${solutionName}'

var tisAppElster  = 'elster-${environmentName}-${solutionName}'

var tisAppAutomation = 'automation-${environmentName}-${solutionName}'

//Env hier wird die subnet-Id benötigt
resource containerEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: 'container-env-${environmentName}-${solutionName}'
  location: location
  properties: {
    zoneRedundant: false
    workloadProfiles: [
      {
        workloadProfileType: 'D4'
        maximumCount:10
        minimumCount:3
        name: 'test'
      }
    ]
  }
}


//AppGui
resource guiApp 'Microsoft.App/containerApps@2023-05-01' = {
  location:location
  name: tisAppGui
  properties: {
   template: {
    containers: [
      {
        name: 'gui-container'
        image: 'mcr.microsoft.com/k8se/quickstart:latest'
        
      }
    ]
   }
   environmentId: containerEnvironment.id
   configuration:{
    ingress: {
      allowInsecure: false
      targetPort: 80
      external: true   
    } 
   }
  } 
}

//App Elster
resource elsterApp 'Microsoft.App/containerApps@2023-05-01' = {
  location:location
  name: tisAppElster
  
  properties: {
   template: {
    containers: [
      {
        name: 'elster-container'
        image: 'mcr.microsoft.com/k8se/quickstart:latest'
       
      }
      
    ]
   }
   environmentId:containerEnvironment.id
   configuration:{
    
    ingress: {
      allowInsecure: false
      targetPort: 80
      
    } 
   }
  } 
}

resource automationApp 'Microsoft.App/containerApps@2023-05-01' = {
  location:location
  name: tisAppAutomation
  properties: {
   template: {
    containers: [
      {
        name: 'automation-container'
        image: 'mcr.microsoft.com/k8se/quickstart:latest'
       
      }
    ]
   }
   environmentId: containerEnvironment.id
   configuration:{
    ingress: {
      allowInsecure: false
      targetPort: 80
    } 
   }
  } 
}



