# Azure function with app configuration

## Overview

This repository contains a c# Azure Function (in-process) project showcasing the use of Azure App Configuration. The
purpose of this demonstration is to illustrate how to implement an application that dynamically receives updates to
its configuration without requiring a restart.

## Prerequisites

- [Azure subscription](https://azure.microsoft.com/en-us/free/)
- [Dotnet core 6.0](https://dotnet.microsoft.com/download/dotnet/6.0)
- [Azure cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

## Getting started

1. Clone the repository

```ps
git clone https://github.com/juulhobert/az-function-with-app-configuration.git
```

2. Modify the `main.bicepparam` file to your needs

3. Deploy the Azure resources

```ps
.\deploy.ps1 <resource-group-name> [subscription-id]
```

4. Open a browser and navigate to the url `https://<function-app-name>.azurewebsites.net/hello-world`

## Demo details

The demo consists of an Azure Function that is triggered by an HTTP request. The function will return the string
`Hello <name>` where `<name>` is a value retrieved from Azure App Configuration. The key feature demonstrated here is
the automatic refreshing of the application configuration without the need for a manual restart. The refresh happens
instantly when the configuration is updated in Azure App Configuration due to the use of Azure Event Grid.

Demo can be visited at `https://<function-app-name>.azurewebsites.net/hello-world`

## Learn more

- [Azure App Configuration](https://docs.microsoft.com/en-us/azure/azure-app-configuration/overview)
- [Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview)
- [Azure Event Grid](https://docs.microsoft.com/en-us/azure/event-grid/overview)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/)
- [Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)

## Contribute

Feel free to contribute to this repository by creating a pull request.

## License

The project is licensed under the apache-2.0 license. See [LICENSE](LICENSE) for details.
