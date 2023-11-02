using System;
using Azure.Identity;
using JuulHobert.Blog.FunctionAppWithAppConfig;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.FeatureManagement;

[assembly: FunctionsStartup(typeof(Startup))]

namespace JuulHobert.Blog.FunctionAppWithAppConfig;

public class Startup : FunctionsStartup
{
    private const string AppConfigEndpointEnvironmentVariableName = "AppConfigEndpoint";

    public override void ConfigureAppConfiguration(IFunctionsConfigurationBuilder builder)
    {
        var credentials = new DefaultAzureCredential();
        var appConfigEndpoint = Environment.GetEnvironmentVariable(AppConfigEndpointEnvironmentVariableName);
        if (string.IsNullOrEmpty(appConfigEndpoint))
        {
            throw new InvalidOperationException("AppConfigEndpoint is not set");
        }

        builder.ConfigurationBuilder.AddAzureAppConfiguration(options =>
            options
                .Connect(new Uri(appConfigEndpoint), credentials)
                .Select($"{ServiceOptions.SectionName}:*")
                .ConfigureKeyVault(kv => kv.SetCredential(credentials))
                .UseFeatureFlags());
    }

    public override void Configure(IFunctionsHostBuilder builder)
    {
        builder.Services
            .AddAzureAppConfiguration()
            .AddFeatureManagement()
            .Services
            .AddOptions<ServiceOptions>()
            .Configure<IConfiguration>((settings, configuration) =>
            {
                configuration.GetSection(ServiceOptions.SectionName).Bind(settings);
            });
    }
}

public class ServiceOptions
{
    public const string SectionName = "JuulHobertBlog";

    public string Name { get; set; } = string.Empty;
}
