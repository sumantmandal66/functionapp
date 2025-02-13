param functionAppName string
param location string
param storageAccountName string
param appServicePlanName string
param applicationInsightsName string
param logAnalyticsWorkspaceName string // Name of the existing Log Analytics Workspace
param appInsightsInstrumentationKey string // New parameter for Application Insights Instrumentation Key
param functionsExtensionVersion string // New parameter for Functions Extension Version
param functionsWorkerRuntime string // New parameter for Functions Worker Runtime
param applicationInsightsConnectionString string // New parameter for Application Insights Connection String
param serviceBusQueueTriggerDisabled string // New parameter for Service Bus Queue Trigger Disabled
param websiteRunFromPackage string // New parameter for WEBSITE_RUN_FROM_PACKAGE
param websiteVnetRouteAll string // New parameter for WEBSITE_VNET_ROUTE_ALL
param storageConnectionString string
param AWSS3AcessKey string
param AWSS3SecretKey string

// Fetch the resource ID for the Storage Account dynamically
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
  name: storageAccountName
  scope: resourceGroup()
}

 //Fetch the Storage Account Keys
 //var storageAccountKey = listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value

// Construct the Connection String
//var storageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccountKey};EndpointSuffix=${environment().suffixes.storage}'

// Create a new App Service Plan in the Consumption plan (Dynamic Tier)
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' existing = {
  name: appServicePlanName // You can use a dynamic name or pass one as a parameter
}

// Fetch the resource ID for Application Insights dynamically
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
  scope: resourceGroup()
}

// Fetch the resource ID of the existing Log Analytics Workspace dynamically
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup()
}

// Function App resource
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: functionsExtensionVersion // Parameterized
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionsWorkerRuntime // Parameterized
        }
        {
          name: 'AzureWebJobsStorage'
          value: storageConnectionString
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey // Parameterized
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsightsConnectionString // Parameterized
        }
        {
          name: 'AzureWebJobs.ServiceBusQueueTrigger1.Disabled'
          value: serviceBusQueueTriggerDisabled // Parameterized
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: websiteRunFromPackage // Parameterized
        }
        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: websiteVnetRouteAll // Parameterized
        }
        {
          name: 'AWSS3AcessKey'
          value: AWSS3AcessKey
        }
        {
          name: 'AWSS3SecretKey'
          value: AWSS3SecretKey
        }
      ]
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ] // Add portal.azure.com to the allowed origins dynamically
      }
    }
  }
}

// Diagnostic Settings for Function App
  resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${functionAppName}-diagnostics'
  scope: functionApp
  properties: {
    logs: [
      {
        category: 'FunctionAppLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspace.id    
  }
}
output functionAppUrl string = functionApp.properties.defaultHostName
