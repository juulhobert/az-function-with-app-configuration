using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;
using Microsoft.Extensions.Logging;

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
        [TimerTrigger("0 * * * * *")] TimerInfo timer,
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
