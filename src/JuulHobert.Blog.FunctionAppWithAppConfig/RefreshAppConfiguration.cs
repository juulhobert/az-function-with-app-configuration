using System.Threading.Tasks;
using Azure.Messaging.EventGrid;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.WebJobs.Extensions.EventGrid;

namespace JuulHobert.Blog.FunctionAppWithAppConfig;

public class RefreshAppConfiguration
{
    private readonly IConfigurationRefresherProvider _refresherProvider;

    public RefreshAppConfiguration(
        IConfigurationRefresherProvider refresherProvider)
    {
        _refresherProvider = refresherProvider;
    }

    [FunctionName("RefreshAppConfiguration")]
    public async Task RunAsync(
        [EventGridTrigger] EventGridEvent eventGridEvent,
        ILogger logger)
    {
        foreach (var refresher in _refresherProvider.Refreshers)
        {
            if (await refresher.TryRefreshAsync())
            {
                logger.LogInformation("Refreshed configuration");
            }
            else
            {
                logger.LogWarning("Failed to refresh configuration");
            }
        }
    }
}
