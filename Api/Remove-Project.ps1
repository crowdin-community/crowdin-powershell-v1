<#
.SYNOPSIS
Delete Crowdin project.

.DESCRIPTION
Delete Crowdin project with all translations.

.PARAMETER ProjectKey
Project API key.

.PARAMETER ProjectId
Should contain the project identifier.

.EXAMPLE
Remove-CrowdinProject -ProjectId apitestproject -ProjectKey 2b680...ce586

#>
function Remove-Project
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
    Invoke-ApiRequest -Url "project/$ProjectId/delete-project?json" -Body $body | Test-Response
}