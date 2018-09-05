$apiMessageHandlerBaseTypeOptions = @{ TypeDefinition = @'
namespace Crowdin.PowerShell.Api1.Http
{
    using System.Net.Http;
    using System.Threading;
    using System.Threading.Tasks;

    public abstract class ApiMessageHandlerBase : DelegatingHandler
    {
        protected ApiMessageHandlerBase() : base(new HttpClientHandler())
        { }

        protected sealed override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            HttpResponseMessage response =
                OnSendingRequest(request) ??
                await base.SendAsync(request, cancellationToken);
            response = OnResponseReceived(request, response);
            return response;
        }

        protected abstract HttpResponseMessage OnSendingRequest(HttpRequestMessage request);

        protected abstract HttpResponseMessage OnResponseReceived(HttpRequestMessage request, HttpResponseMessage response);
    }
}
'@ }
if ($PSVersionTable.PSVersion.Major -lt 6)
{
    $apiMessageHandlerBaseTypeOptions.ReferencedAssemblies = 'System.Net.Http'
    $apiMessageHandlerBaseTypeOptions.WarningAction = 'SilentlyContinue'
}
Add-Type @apiMessageHandlerBaseTypeOptions
Remove-Variable -Name apiMessageHandlerBaseTypeOptions