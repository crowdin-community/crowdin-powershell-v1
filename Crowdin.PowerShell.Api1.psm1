New-Variable ApiBaseUrl -Value ([uri]'https://api.crowdin.com/api/') -Option Constant
New-Variable HttpClient -Value (New-Object System.Net.Http.HttpClient -Property @{BaseAddress=$ApiBaseUrl}) -Option Constant

. .\ConvertFrom-PSCmdlet.ps1
. .\ConvertTo-MultipartFormDataContent.ps1

function Invoke-GetRequest
{
    [OutputType([System.Net.Http.HttpResponseMessage])]
    param (
        [Parameter(Mandatory)]
        [uri]$Url
    )

    $HttpClient.GetAsync($Url).GetAwaiter().GetResult()
}

function Invoke-PostRequest
{
    [OutputType([System.Net.Http.HttpResponseMessage])]
    param (
        [Parameter(Mandatory)]
        [uri]$Url,

        [Parameter(Mandatory)]
        [System.Net.Http.MultipartFormDataContent]
        $Content
    )

    $HttpClient.PostAsync($Url, $Content).GetAwaiter().GetResult()
}

function Invoke-ApiRequest
{
    [CmdletBinding(DefaultParameterSetName='GET')]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory, Position=0)]
        [uri]$Url,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName='POST')]
        [psobject]$Body
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'GET')
        {
            $response = Invoke-GetRequest -Url $Url
        }
        else
        {
            $content = ConvertTo-MultipartFormDataContent -Object $Body
            try {
                $response = Invoke-PostRequest -Url $Url -Content $content
            }
            finally {
                $content.Dispose()
            }
        }
        $json = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
        ConvertFrom-Json -InputObject $json
    }
}

function Test-Response
{
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline)]
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
