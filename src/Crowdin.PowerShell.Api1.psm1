New-Variable ApiBaseUrl -Value ([uri]'https://api.crowdin.com/api/') -Option Constant
New-Variable HttpClient -Value (New-Object System.Net.Http.HttpClient -Property @{BaseAddress=$ApiBaseUrl}) -Option Constant

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here/ConvertFrom-PSCmdlet.ps1"
. "$here/Format-RequestBody.ps1"
. "$here/ConvertTo-MultipartFormDataContent.ps1"

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
        [string]$OutDir,

        [Parameter()]
        [string]$EntityTag
    )

    process {
        $request = if ($PSCmdlet.ParameterSetName -eq 'GET')
        {
            New-Object System.Net.Http.HttpRequestMessage -ArgumentList @([System.Net.Http.HttpMethod]::Get, $Url)
        }
        else
        {
            $content = $Body | Format-RequestBody | ConvertTo-MultipartFormDataContent
            New-Object System.Net.Http.HttpRequestMessage -ArgumentList @([System.Net.Http.HttpMethod]::Post, $Url) -Property @{Content=$content}
        }
        if ($EntityTag)
        {
            [void]$request.Headers.TryAddWithoutValidation('If-None-Match', $EntityTag)
        }

        $request | Send-ApiRequest | Receive-ApiResponse -OutDir $OutDir
    }
}

function Send-ApiRequest
{
    [OutputType([System.Net.Http.HttpResponseMessage])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Net.Http.HttpRequestMessage]$Request
    )
    process {
        $HttpClient.SendAsync($Request).GetAwaiter().GetResult()
    }
}

function Receive-ApiResponse
{
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Net.Http.HttpResponseMessage]$Response,

        [Parameter()]
        [string]$OutDir
    )
    process {
        $result = if ($Response.StatusCode -eq [System.Net.HttpStatusCode]::NotModified)
        {
            [PSCustomObject]@{ Success = $true }
        }
        elseif ($Response.Content.Headers.ContentDisposition)
        {
            Save-ApiResponse -Content $Response.Content -OutDir $OutDir
        }
        else
        {
            Read-ApiResponse -Content $Response.Content | Test-ApiResponse
        }

        $etag = $null
        if ($Response.Headers.TryGetValues('ETag', [ref]$etag))
        {
            Add-Member -InputObject $result -NotePropertyName 'EntityTag' -NotePropertyValue $etag[0]
        }
        $result
    }
}

function Read-ApiResponse
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

function Save-ApiResponse
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
        [IO.Path]::Combine($OutDir, $fileName).Replace([IO.Path]::AltDirectorySeparatorChar, [IO.Path]::DirectorySeparatorChar)
    }
}

function Test-ApiResponse
{
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $Response
    )
    process {
        if ((-not $Response.Success) -and (Get-Member -InputObject $Response -Name 'Error' -MemberType NoteProperty))
        {
            throw $Response.Error
        }
        $Response
    }
}

$ExecutionContext.SessionState.Module.OnRemove = {
    $HttpClient.Dispose()
    Clear-Variable -Name HttpClient
}
