<#
.SYNOPSIS
Translation status of the project.

.DESCRIPTION
Track overall translation and proofreading progresses of each target language.

.PARAMETER ProjectId
Should contain the project identifier.

.PARAMETER ProjectKey
Project API key.

.EXAMPLE
PS C:\> Measure-CrowdinProject -ProjectId apitestproject -ProjectKey 2b680...ce586
#>
function Measure-Project
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias('identifier')]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [Alias('key')]
        [string]$ProjectKey
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId
    Invoke-ApiRequest -Url "project/$ProjectId/status?json" -Body $body
}