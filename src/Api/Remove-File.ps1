<#
.SYNOPSIS
Delete file.

.DESCRIPTION
Delete file from Crowdin project. All the translations will be lost without ability to restore them.

.PARAMETER ProjectKey
Project API key.

.PARAMETER ProjectId
Should contain the project identifier.

.PARAMETER Name
Name of the file that should be deleted.

.PARAMETER Branch
The name of related version branch.

.EXAMPLE
Remove-CrowdinFile -ProjectId apitestproject -ProjectKey 2b680...ce586 -Name 'test.xml'

#>
function Remove-File
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias('identifier')]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [Alias('key')]
        [string]$ProjectKey,

        [Parameter(Mandatory)]
        [Alias('file')]
        [string]$Name,

        [Parameter()]
        [string]$Branch
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId
    Invoke-ApiRequest -Url "project/$ProjectId/delete-file?json" -Body $body
}