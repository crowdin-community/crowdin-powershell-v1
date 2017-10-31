New-Variable ApiBaseUrl -Value ([uri]'https://api.crowdin.com/api/') -Option Constant
New-Variable HttpClient -Value (New-Object System.Net.Http.HttpClient -Property @{BaseAddress=$ApiBaseUrl}) -Option Constant

function Invoke-ApiRequest
{
    [CmdletBinding(DefaultParameterSetName='GET')]
    [OutputType([PSCustomObject])]
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
    $json = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult();
    ConvertFrom-Json -InputObject $json
}

function Test-Response
{
    param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        $Response
    )
    process {
        if ((Get-Member -InputObject $Response -Name 'Error' -MemberType NoteProperty) -and (-not $Response.Success))
        {
            throw $Response.Error
        }
        $Response
    }
}

$ExecutionContext.SessionState.Module.OnRemove = {
    Clear-Variable -Name HttpClient
}
