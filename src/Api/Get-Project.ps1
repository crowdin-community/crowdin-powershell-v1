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
PS C:\> Get-CrowdinProject -ProjectId apitestproject -ProjectKey 2b680...ce586 | Select-Object -ExpandProperty details

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
    [CmdletBinding(DefaultParameterSetName = 'AccountKey')]
    param (
        [Parameter(Mandatory)]
        [string]$ProjectId,

        [Parameter(Mandatory, ParameterSetName = 'ProjectKey')]
        [Alias('key')]
        [string]$ProjectKey,

        [Parameter(Mandatory, ParameterSetName = 'AccountKey')]
        [Alias('login')]
        [string]$LoginName,

        [Parameter(Mandatory, ParameterSetName = 'AccountKey')]
        [Alias('account-key')]
        [string]$AccountKey
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId
    Invoke-ApiRequest -Url "project/$ProjectId/info?json" -Body $body
}