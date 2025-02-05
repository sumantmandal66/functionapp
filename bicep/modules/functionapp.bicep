param functionAppName string
param location string = 'East US'
param storageAccountName string
param appServicePlanName string

// Reference the existing Storage Account
resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

// Reference the existing App Service Plan
resource appServicePlan 'Microsoft.Web/serverFarms@2021-02-01' existing = {
  name: appServicePlanName
}

// Deploy the Function App using the existing resources
resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id  // Reference the existing App Service Plan
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storage.properties.primaryEndpoints.blob  // Reference the existing Storage Account
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'  // Change to your desired runtime (node, python, etc.)
        }
      ]
    }
  }
}
