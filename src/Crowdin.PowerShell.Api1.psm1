New-Variable ApiBaseUrl -Value ([uri]'https://api.crowdin.com/api/') -Option Constant
New-Variable HttpClient -Value (New-Object System.Net.Http.HttpClient -Property @{BaseAddress=$ApiBaseUrl}) -Option Constant

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here/ConvertFrom-PSCmdlet.ps1"
. "$here/Format-RequestBody.ps1"
. "$here/ConvertTo-MultipartFormDataContent.ps1"

function Invoke-GetRequest
{
    [OutputType([System.Net.Http.HttpResponseMessage])]
    param (
        [Parameter(Mandatory)]
        [uri]$Url
    )
    process {
        $HttpClient.GetAsync($Url).GetAwaiter().GetResult()
    }
}

function Invoke-PostRequest
{
    [OutputType([System.Net.Http.HttpResponseMessage])]
    param (
        [Parameter(Mandatory)]
        [uri]$Url,

        [Parameter(Mandatory)]
        [psobject]$Body
    )
    process {
        $content = $Body | ConvertTo-MultipartFormDataContent
        try {
            $HttpClient.PostAsync($Url, $Content).GetAwaiter().GetResult()
        }
        finally {
            $content.Dispose()
        }
    }
}

function Invoke-ApiRequest
{
    [CmdletBinding(DefaultParameterSetName='GET')]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory, Position=0)]
        [uri]$Url,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName='POST')]
        [psobject]$Body,

        [Parameter()]
        [string]$OutDir
    )

    process {
        $response = if ($PSCmdlet.ParameterSetName -eq 'GET')
        {
            Invoke-GetRequest -Url $Url
        }
        else
        {
            Invoke-PostRequest -Url $Url -Body (Format-RequestBody -InputObject $Body)
        }

        $responseContent = $response.Content
        if ($responseContent.Headers.ContentDisposition)
        {
            Save-File -Content $responseContent -OutDir $OutDir
        }
        else
        {
            Read-Response -Content $responseContent | Test-Response
        }
    }
}

function Save-File
{
    param (
        [Parameter(Mandatory)]
        [System.Net.Http.HttpContent]$Content,

        [Parameter(Mandatory)]
        [string]$OutDir
    )
    process {
        $outFile = Resolve-OutFileName -OutDir $OutDir -ContentDisposition $Content.Headers.ContentDisposition
        if (-not (Test-Path -LiteralPath $outFile -IsValid))
        {
            throw "Invalid file name: `"$outFile`"."
        }
        $outStream = [System.IO.File]::Create($outFile)
        try {
            [void]$Content.CopyToAsync($outStream).GetAwaiter().GetResult()
        }
        finally {
            $outStream.Dispose()
        }

        [PSCustomObject]@{
            Success = $true
            File = [System.IO.FileInfo]$outFile
        }
    }
}

function Read-Response
{
    param (
        [Parameter(Mandatory)]
        [System.Net.Http.HttpContent]$Content
    )
    process {
        if ($Content.Headers.ContentType.MediaType -ne 'application/json')
        {
            throw "Only JSON content is acceptable."
        }
        $json = $Content.ReadAsStringAsync().GetAwaiter().GetResult()
        ConvertFrom-Json -InputObject $json
    }
}

function Resolve-OutFileName
{
    param (
        [Parameter(Mandatory)]
        [string]$OutDir,

        [Parameter(Mandatory)]
        [System.Net.Http.Headers.ContentDispositionHeaderValue]$ContentDisposition
    )
    process {
        $fileName = $ContentDisposition.FileName.Trim('"')
        (Join-Path -Path $OutDir -ChildPath $fileName).Replace('\', '/')
    }
}

function Test-Response
{
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
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
