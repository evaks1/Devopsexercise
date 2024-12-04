@description('The location for the resources')
param location string = resourceGroup().location

module acr './modules/azureContainerRegistry.bicep' = {
  name: 'acrModule'
  params: {
    name: 'ElsExerciseACR'
    location: location
    acrAdminUserEnabled: true
  }
}

module keyVault './modules/keyVault.bicep' = {
  name: 'keyVaultModule'
  params: {
    name: 'ElsExerciseKeyVault'
    location: location
    enableVaultForDeployment: true
    roleAssignments: [
      {
        principalId: 'some-principal-id'
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
module appServicePlan './modules/appServicePlan.bicep' = {
  name: 'appServicePlanModule'
  params: {
    name: 'ElsExerciseAppServicePlan'
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    kind: 'Linux'
    reserved: true
  }
}

module webApp './modules/webApp.bicep' = {
  name: 'webAppModule'
  params: {
    name: 'ElsExerciseWebApp'
    location: location
    kind: 'app'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    siteConfig: {
      linuxFxVersion: 'DOCKER|ElsExerciseACR.azurecr.io/myImage:latest'
      appCommandLine: ''
    }
  }
}
