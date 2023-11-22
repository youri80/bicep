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


var tisAppGui = 'app-gui-${environmentName}-${solutionName}'

var tisAppElster  = 'app-elster-${environmentName}-${solutionName}'

var tisAppAutomation = 'app-automation-${environmentName}-${solutionName}'

//Env hier wird die subnet-Id benötigt



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
   configuration:{
    ingress: {
      allowInsecure: false
      targetPort: 80
      stickySessions: 'sticky'  
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
   environmentId: 
   configuration:{
    
    ingress: {
      allowInsecure: false
      targetPort: 80
      stickySessions: null  
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
   configuration:{
    ingress: {
      allowInsecure: false
      targetPort: 80
      stickySessions: null  
    } 
   }
  } 
}



