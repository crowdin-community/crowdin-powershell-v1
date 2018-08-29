using namespace System.Net
using namespace System.Net.Http
using namespace System.Threading
using namespace System.Threading.Tasks
using namespace Crowdin.PowerShell.Api1.Http

class ApiMessageHandler : ApiMessageHandlerBase
{
    hidden [HttpResponseMessage] OnSendingRequest([HttpRequestMessage]$request)
    {
        Write-Verbose ([ApiMessageHandler]::FormatRequest($request))

        $response = if ($PSCmdlet.ShouldProcess($request.RequestUri, $request.Method))
        {
            $null
        }
        else
        {
            [ApiMessageHandler]::BuildFakeResponse($request)
        }
        return $response
    }

    hidden [HttpResponseMessage] OnResponseReceived([HttpRequestMessage]$request, [HttpResponseMessage]$response)
    {
        return $response
    }

    hidden static [string] FormatRequest([HttpRequestMessage]$request)
    {
        return $request.ToString()
    }

    hidden static [HttpResponseMessage] BuildFakeResponse([HttpRequestMessage]$request)
    {
        $responseContent = [StringContent]::new('{"success":true}')
        $responseContent.Headers.ContentType = [Headers.MediaTypeHeaderValue]::Parse('application/json')
        $response = New-Object System.Net.Http.HttpResponseMessage @([HttpStatusCode]::NonAuthoritativeInformation) -Property @{
            RequestMessage = $request
            ReasonPhrase = 'Fake Response'
            Content = $responseContent
        }
        return $response
    }
}
