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
PS C:\> Get-CrowdinAccountProject -AccountKey 1978a...f9f54 -LoginName yurko7

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
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [Alias('account-key')]
        [string]$AccountKey,

        [Parameter(Mandatory=$true)]
        [Alias('login')]
        [string]$LoginName
    )

    $AccountKey = [Uri]::EscapeDataString($AccountKey)
    $LoginName = [Uri]::EscapeDataString($LoginName)
    $response = Invoke-ApiRequest -Url "account/get-projects?json&account-key=$AccountKey&login=$LoginName" | Test-Response
    $response.Projects
}