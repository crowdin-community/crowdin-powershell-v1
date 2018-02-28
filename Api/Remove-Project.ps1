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
Remove-CrowdinProject -ProjectKey 2b680...ce586 -ProjectId apitestproject

#>
function Remove-Project
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias('key')]
        [string]$ProjectKey,

        [Parameter(Mandatory)]
        [Alias('identifier')]
        [string]$ProjectId
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $ProjectKey = [Uri]::EscapeDataString($ProjectKey)
    Invoke-ApiRequest -Url "project/$ProjectId/delete-project?json&key=$ProjectKey" | Test-Response
}