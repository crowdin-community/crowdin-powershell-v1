<#
.SYNOPSIS
Create Crowdin project.

.DESCRIPTION
Create and configure Crowdin project.

.PARAMETER AccountKey
Crowdin account API key.

.PARAMETER LoginName
Your Crowdin Account login name.

.PARAMETER ProjectId
Project identifier. Should be unique among other Crowdin projects.

.PARAMETER Name
Project name.

.PARAMETER SourceLanguage
Source files language. Crowdin language code.

.PARAMETER Languages
An array of language codes project should be translate to.

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

.PARAMETER InContext
Defines whether the In-Context should be active in the project.

.PARAMETER PseudoLanguage
Specify the language code for the In-Context's pseudo-language that will store some operational data.

.PARAMETER QAChecks
Defines whether the QA checks should be active in the project.
As a key you must specify QA check parameter.

.PARAMETER WebhookFileTranslated
Open this URL when one of the project files is translated. URL will be opened with "project" - project identifier,
"language" - language code, "file_id" - Crowdin file identifier and "file" - file name.

.PARAMETER WebhookFileProofread
Open this URL when one of the project files is proofread. URL will be opened with "project" - project identifier,
"language" - language code, "file_id" - Crowdin file identifier and "file" - file name.

.PARAMETER WebhookProjectTranslated
Open this URL when project translation is complete. URL will be opened with "project" - project identifier and "language" - language code.

.PARAMETER WebhookProjectProofread
Open this URL when project proofreading is complete. URL will be opened with "project" - project identifier and "language" - language code.

.EXAMPLE
PS C:\> New-CrowdinProject -LoginName yurko7 -AccountKey 1978a...f9f54

#>
function New-Project
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('login')]
        [string]$LoginName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('account-key')]
        [string]$AccountKey,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('identifier')]
        [string]$ProjectId,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('source_language')]
        [string]$SourceLanguage,

        [Parameter(Mandatory)]
        [string[]]$Languages,

        [Parameter(Mandatory)]
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
        [System.IO.FileInfo]$Logo,

        [Parameter()]
        [Alias('cname')]
        [string]$DomainName,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [Alias('in_context')]
        [switch]$InContext,

        [Parameter()]
        [Alias('pseudo_language')]
        [string]$PseudoLanguage,

        [Parameter()]
        [Alias('qa_checks')]
        [hashtable]$QAChecks,

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

    $body = $PSCmdlet | ConvertFrom-PSCmdlet
    Invoke-ApiRequest -Url "account/create-project?json" -Body $body | Test-Response
}