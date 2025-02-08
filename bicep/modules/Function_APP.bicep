param functionAppName string
param resourceGroupName string
param location string
param storageAccountId string
param appServicePlanId string
param applicationInsightsId string

// Function App resource
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4' // Use the version that suits your requirements
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node' // You can change this to 'dotnet', 'python', etc.
        }
        {
          name: 'AzureWebJobsStorage'
          value: storageAccountId
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsightsId
        }
      ]
    }
  }
}

// Diagnostic Settings
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01' = {
  name: '${functionAppName}-diagnostics'
  scope: functionApp
  properties: {
    logs: [
      {
        category: 'FunctionAppLogs'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
      {
        category: 'ApplicationInsights'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
    destination: [
      {
        azureMonitor: {}
      }
      {
        eventHub: {} // Optional: You can add EventHub, LogAnalytics, etc. as destinations
      }
    ]
  }
}

output functionAppUrl string = functionApp.properties.defaultHostName
