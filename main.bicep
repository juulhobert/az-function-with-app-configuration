@description('Name of the azure function')
param funcName string

@description('Default location to deploy resources')
param location string

@description('Name of the storage account')
param storageName string

@description('App configuration name')
param appConfigName string

@description('Service plan name')
param servicePlanName string

@description('App configuration event grid topic name')
param eventGridTopicName string

param skuAppConfig string = 'free'
param skuServicePlan string = 'Y1'
param skuServicePlanTier string = 'Dynamic'
param skuStorage string = 'Standard_LRS'
param refreshFunctionName string = 'RefreshAppConfiguration'

var readerRoleDefinitionId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
var appConfigurationReaderRoleDefinitionId = '516239f1-63e1-4d78-a4de-a74fb236a071'

resource appConfiguration 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
    name: appConfigName
    location: location
    sku: {
        name: skuAppConfig
    }

    resource featureFlagConfigName 'keyValues' = {
        name: '.appconfig.featureflag~2FConfigName'
        properties: {
            value: '{"id": "ConfigName", "description": "ConfigName", "enabled": true, "conditions": {}}'
            contentType: 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'
        }
    }

    resource configName 'keyValues' = {
        name: 'JuulHobertBlog:Name'
        properties: {
            value: 'Juul'
        }
    }
}

resource servicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
    name: servicePlanName
    location: location
    kind: 'functionapp'
    sku: {
        name: skuServicePlan
        tier: skuServicePlanTier
    }
}

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
    name: storageName
    location: location
    kind: 'StorageV2'
    sku: {
        name: skuStorage
    }
}

resource function 'Microsoft.Web/sites@2020-12-01' = {
    name: funcName
    location: location
    kind: 'functionapp'
    identity: {
        type: 'SystemAssigned'
    }
    properties: {
        serverFarmId: servicePlan.id
        httpsOnly: true
    }

    resource functionSettings 'config' = {
        name: 'appsettings'
        properties: {
            FUNCTIONS_WORKER_RUNTIME: 'dotnet'
            FUNCTIONS_EXTENSION_VERSION: '~4'
            WEBSITE_RUN_FROM_PACKAGE: '1'
            AppConfigEndpoint: appConfiguration.properties.endpoint
            AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageName};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
        }
    }
}

resource appConfigTopic 'Microsoft.EventGrid/systemTopics@2023-12-15-preview' = {
    name: eventGridTopicName
    location: location
    properties: {
        source: appConfiguration.id
        topicType: 'Microsoft.AppConfiguration.ConfigurationStores'
    }

    resource appConfigTopicSubscription 'eventSubscriptions' = {
      name: 'configChangeToFunc'
      properties: {
        destination: {
          endpointType: 'AzureFunction'
          properties: {
            resourceId: '${function.id}/functions/${refreshFunctionName}'
            maxEventsPerBatch: 1
            preferredBatchSizeInKilobytes: 64
          }
        }
        eventDeliverySchema: 'EventGridSchema'
        filter: {
          includedEventTypes: [
            'Microsoft.AppConfiguration.KeyValueModified'
            'Microsoft.AppConfiguration.KeyValueDeleted'
          ]
        }
      }
    }
}

resource functionRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleAssignment in [ readerRoleDefinitionId, appConfigurationReaderRoleDefinitionId ]: {
    scope: appConfiguration
    name: guid(appConfiguration.id, function.id, roleAssignment)
    properties: {
        roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleAssignments@2022-04-01', roleAssignment)
        principalId: function.identity.principalId
        principalType: 'ServicePrincipal'
    }
}]

output funcName string = funcName
