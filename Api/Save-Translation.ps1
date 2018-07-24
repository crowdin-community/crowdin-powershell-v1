function Save-Translation
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [Alias('key')]
        [string]$ProjectKey,

        [Parameter(Mandatory)]
        [string]$Package,

        [Parameter()]
        [string]$OutDir = (Get-Location)
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $ProjectKey = [Uri]::EscapeDataString($ProjectKey)
    $Package = [Uri]::EscapeDataString($Package)
    $response = Invoke-ApiRequest -Url "project/$ProjectId/download/$Package.zip?key=$ProjectKey&json" -OutDir $OutDir | Test-Response
    $response.File
}