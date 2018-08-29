<#
.SYNOPSIS
Language status.

.DESCRIPTION
Get the detailed translation progress for specified language.

.PARAMETER ProjectId
Should contain the project identifier.

.PARAMETER ProjectKey
Project API key.

.PARAMETER Language
Crowdin language code.

.EXAMPLE
An example

.NOTES
General notes
#>
function Measure-Language
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [Alias('identifier')]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [Alias('key')]
        [string]$ProjectKey,

        [Parameter(Mandatory)]
        [string]$Language
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId
    Invoke-ApiRequest -Url "project/$ProjectId/language-status?json" -Body $body
}