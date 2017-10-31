New-Variable ApiBaseUrl -Value ([uri]'https://api.crowdin.com/api/') -Option Constant
New-Variable HttpClient -Value (New-Object System.Net.Http.HttpClient -Property @{BaseAddress=$ApiBaseUrl}) -Option Constant

function Invoke-ApiRequest
{
    [CmdletBinding(DefaultParameterSetName='GET')]
    [OutputType([xml])]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [uri]$Url,

        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName='POST')]
        [psobject]$Body
    )

    if ($PSCmdlet.ParameterSetName -eq 'GET')
    {
        $responseTask = $HttpClient.GetAsync($Url);
    }
    else
    {
        $content = New-Object System.Net.Http.MultipartFormDataContent
        $Body | Get-Member -MemberType Properties | ForEach-Object {
            $partName = $_.Name
            $partValue = $Body.($_.Name)
            $contentPart = New-Object System.Net.Http.StringContent -ArgumentList $partValue
            $content.Add($contentPart, $partName)
        }
        $responseTask = $HttpClient.PostAsync($Url, $content);
    }
    $response = $responseTask.GetAwaiter().GetResult();
    [xml]$response.Content.ReadAsStringAsync().GetAwaiter().GetResult();
}

function Test-Response
{
    [OutputType([xml])]
    param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [xml]$Response
    )
    process {
        if ($Response.DocumentElement.Name -eq 'error')
        {
            throw "$($Response.Error.Code): $($Response.Error.Message)"
        }
        $Response
    }
}

$ExecutionContext.SessionState.Module.OnRemove = {
    Clear-Variable -Name HttpClient
}
