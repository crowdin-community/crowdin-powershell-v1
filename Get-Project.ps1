<#
.SYNOPSIS
Get Crowdin Project details.

.DESCRIPTION
Get details, files and languages of Crowdin Project.

.PARAMETER ProjectKey
Project API key.

.PARAMETER ProjectId
Should contain the project identifier.

.EXAMPLE
PS C:\> Get-CrowdinProject -ProjectKey 2b680...ce586 -ProjectId apitestproject | Select-Object -ExpandProperty details

source_language         : @{name=English; code=en}
name                    : ApiTestProject
identifier              : apitestproject
created                 : 2017-10-29T20:44:43+0000
description             :
join_policy             : private
last_build              : 2017-11-12T18:24:46+0000
last_activity           : 2017-10-29T20:44:43+0000
participants_count      : 1
logo_url                :
total_strings_count     : 0
total_words_count       :
duplicate_strings_count : 0
duplicate_words_count   : 0
invite_url              : @{translator=https://crowdin.com/project/apitestproject/invite?d=55b...353; proofreader=https://crowdin.com/project/apitestproject/invite?d=15b...353}

#>
function Get-Project
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [Alias('key')]
        [string]$ProjectKey,

        [Parameter(Mandatory=$true)]
        [Alias('id')]
        [string]$ProjectId
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $ProjectKey = [Uri]::EscapeDataString($ProjectKey)
    Invoke-ApiRequest -Url "project/$ProjectId/info?json&key=$ProjectKey" | Test-Response
}