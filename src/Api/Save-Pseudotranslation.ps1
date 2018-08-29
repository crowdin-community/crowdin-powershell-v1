function Save-Pseudotranslation
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [Alias('key')]
        [string]$ProjectKey,

        [Parameter()]
        [string]$OutDir = (Get-Location)
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $ProjectKey = [Uri]::EscapeDataString($ProjectKey)
    $response = Invoke-ApiRequest -Url "project/$ProjectId/pseudo-download?key=$ProjectKey&json" -OutDir $OutDir
    $response.File
}