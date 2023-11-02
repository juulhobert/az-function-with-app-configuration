using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Options;
using Microsoft.FeatureManagement;

namespace JuulHobert.Blog.FunctionAppWithAppConfig;

public class HelloWorld
{
    private const string FeatureConfigName = "ConfigName";

    private readonly IOptions<ServiceOptions> _options;
    private readonly IFeatureManager _featureManager;

    public HelloWorld(
        IOptions<ServiceOptions> options,
        IFeatureManager featureManager)
    {
        _options = options;
        _featureManager = featureManager;
    }

    [FunctionName("HelloWorld")]
    public async Task<IActionResult> Run(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "hello-world")]
        HttpRequest req)
    {
        var featureEnabled = await _featureManager.IsEnabledAsync(FeatureConfigName);
        var content = featureEnabled ? $"Hello {_options.Value.Name}" : "Hello World!";

        return new ContentResult
        {
            Content = content, ContentType = "text/plain"
        };
    }
}
