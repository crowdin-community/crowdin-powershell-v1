<#
.SYNOPSIS
Get projects list.

.DESCRIPTION
Ge list of projects owned by specified account.

.PARAMETER AccountKey
Account API key (profile settings -> "API & SSO" tab).

.PARAMETER LoginName
Your Crowdin Account login name.

.EXAMPLE
PS C:\> Get-CrowdinAccountProject -LoginName yurko7 -AccountKey 1978a...f9f54 | Select-Object -ExpandProperty Projects

role         : owner
name         : ExploreCrowdin
identifier   : explorecrowdin
downloadable : 1
key          : c4d40...a1452

role         : owner
name         : ApiTestProject
identifier   : apitestproject
downloadable : 1
key          : 2b680...ce586

#>
function Get-AccountProject
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [Alias('login')]
        [string]$LoginName,

        [Parameter(Mandatory)]
        [Alias('account-key')]
        [string]$AccountKey
    )

    $body = $PSCmdlet | ConvertFrom-PSCmdlet
    Invoke-ApiRequest -Url 'account/get-projects?json' -Body $body
}