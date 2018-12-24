<#
.SYNOPSIS
Edit Crowdin project.

.DESCRIPTION
Edit Crowdin project.

.PARAMETER ProjectKey
Project API key.

.PARAMETER ProjectId
Should contain the project identifier.

.PARAMETER Name
Project name.

.PARAMETER Languages
An array of language codes a project should be translate to.

.PARAMETER JoinPolicy
Project join policy.

.PARAMETER LanguageAccessPolicy
Defines how project members can access target languages.

.PARAMETER HideDuplicates
Defines whether duplicated strings should be displayed to translators or should be hidden and translated automatically.

.PARAMETER ExportTranslatedOnly
Defines whether only translated strings will be exported to the final file.

.PARAMETER ExportApprovedOnly
If set, only approved translations will be exported in resulted ZIP file.

.PARAMETER AutoTranslateDialects
Untranslated strings of dialect will be translated automatically in exported file, leveraging translations from main language.

.PARAMETER PublicDownloads
Defines whether "Download" button visible to everyone on Crowdin webpages.

.PARAMETER UseGlobalTM
Defines if translations would be leveraged from Crowdin Global Translation Memory.
When using this option any translations made in your project will be commited to Crowdin Global TM automatically.

.PARAMETER Logo
Project logo at Crowdin.

.PARAMETER DomainName
Custom domain name for Crowdin project.

.PARAMETER Description
Project description.

.PARAMETER QAChecks
Defines whether the QA checks should be active in the project. As a key you must specify QA check parameter.

.PARAMETER WebhookFileTranslated
Open this URL when one of the project files is translated. URL will be opened with "project" - project identifier,
"language" - language code and "file" - file name.

.PARAMETER WebhookFileProofread
Open this URL when one of the project files is proofread. URL will be opened with "project" - project identifier,
"language" - language code and "file" - file name.

.PARAMETER WebhookProjectTranslated
Open this URL when project translation is complete. URL will be opened with "project" - project identifier and "language" - language code.

.PARAMETER WebhookProjectProofread
Open this URL when project proofreading is complete. URL will be opened with "project" - project identifier and "language" - language code.

.EXAMPLE
PS C:\> Edit-CrowdinProject -ProjectId apitestproject -ProjectKey 2b680...ce586

#>
function Edit-Project
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
        [string]$AccountKey,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]$Languages,

        [Parameter()]
        [ValidateSet('open', 'private')]
        [Alias('join_policy')]
        [string]$JoinPolicy,

        [Parameter()]
        [ValidateSet('open', 'moderate')]
        [Alias('language_access_policy')]
        [string]$LanguageAccessPolicy,

        [Parameter()]
        [Alias('hide_duplicates')]
        [ValidateRange(0, 3)]
        [int]$HideDuplicates,

        [Parameter()]
        [Alias('export_translated_only')]
        [switch]$ExportTranslatedOnly,

        [Parameter()]
        [Alias('export_approved_only')]
        [switch]$ExportApprovedOnly,

        [Parameter()]
        [Alias('auto_translate_dialects')]
        [switch]$AutoTranslateDialects,

        [Parameter()]
        [Alias('public_downloads')]
        [switch]$PublicDownloads,

        [Parameter()]
        [Alias('use_global_tm')]
        [switch]$UseGlobalTM,

        [Parameter()]
        $Logo,

        [Parameter()]
        [Alias('cname')]
        [string]$DomainName,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [Alias('qa_checks')]
        [ValidateScript({
            $_ -is [psobject] -or $_ -is [System.Collections.IDictionary]
        })]
        $QAChecks,

        [Parameter()]
        [Alias('webhook_file_translated')]
        [string]$WebhookFileTranslated,

        [Parameter()]
        [Alias('webhook_file_proofread')]
        [string]$WebhookFileProofread,

        [Parameter()]
        [Alias('webhook_project_translated')]
        [string]$WebhookProjectTranslated,

        [Parameter()]
        [Alias('webhook_project_proofread')]
        [string]$WebhookProjectProofread
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId | Resolve-File -FileProperty Logo
    Invoke-ApiRequest -Url "project/$ProjectId/edit-project?json" -Body $body
}