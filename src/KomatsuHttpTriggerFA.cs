using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace Company.Function
{
    public class KomatsuHttpTriggerFA
    {
        private readonly ILogger<KomatsuHttpTriggerFA> _logger;

        public KomatsuHttpTriggerFA(ILogger<KomatsuHttpTriggerFA> logger)
        {
            _logger = logger;
        }

        [Function("KomatsuHttpTriggerFA")]
        public IActionResult Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req)
        {
            try
            {
                _logger.LogInformation("C# HTTP trigger function processed a request.");
                return new OkObjectResult("Welcome to Azure Functions!");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An error occurred while processing the request.");
                return new BadRequestObjectResult(ex.Message);
            }
        }
    }
}
