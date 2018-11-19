function Save-Glossary
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [Alias('key')]
        [string]$ProjectKey,

        [Parameter()]
        [Alias('include_assigned')]
        [switch]$IncludeAssigned,

        [Parameter()]
        [string]$OutDir = (Get-Location)
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId,OutDir
    Invoke-ApiRequest -Url "project/$ProjectId/download-glossary?json" -Body $body -OutDir $OutDir
}