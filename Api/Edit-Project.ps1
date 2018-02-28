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
PS C:\> Edit-CrowdinProject -ProjectKey 2b680...ce586 -ProjectId apitestproject

#>
function Edit-Project
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('key')]
        [string]$ProjectKey,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('identifier')]
        [string]$ProjectId,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter()]
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
        [System.IO.FileInfo]$Logo,

        [Parameter()]
        [Alias('cname')]
        [string]$DomainName,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [Alias('qa_checks')]
        [System.Collections.HashTable]$QAChecks,

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
    $body = [pscustomobject]@{
        'key' = $ProjectKey
    }
    if ($PSBoundParameters.ContainsKey('Name'))
    {
        $body | Add-Member 'name' $Name
    }
    if ($PSBoundParameters.ContainsKey('Languages'))
    {
        for ($i = 0; $i -lt $Languages.Length; $i++)
        {
            $body | Add-Member "languages[$i]" $Languages[$i]
        }
    }
    if ($PSBoundParameters.ContainsKey('JoinPolicy'))
    {
        $body | Add-Member 'join_policy' $JoinPolicy
    }
    if ($PSBoundParameters.ContainsKey('LanguageAccessPolicy'))
    {
        $body | Add-Member 'language_access_policy' $LanguageAccessPolicy
    }
    if ($PSBoundParameters.ContainsKey('HideDuplicates'))
    {
        $body | Add-Member 'hide_duplicates' $HideDuplicates
    }
    if ($PSBoundParameters.ContainsKey('ExportTranslatedOnly'))
    {
        $body | Add-Member 'export_translated_only' ([int]$ExportTranslatedOnly.ToBool())
    }
    if ($PSBoundParameters.ContainsKey('ExportApprovedOnly'))
    {
        $body | Add-Member 'export_approved_only' ([int]$ExportApprovedOnly.ToBool())
    }
    if ($PSBoundParameters.ContainsKey('AutoTranslateDialects'))
    {
        $body | Add-Member 'auto_translate_dialects' ([int]$AutoTranslateDialects.ToBool())
    }
    if ($PSBoundParameters.ContainsKey('PublicDownloads'))
    {
        $body | Add-Member 'public_downloads' ([int]$PublicDownloads.ToBool())
    }
    if ($PSBoundParameters.ContainsKey('UseGlobalTM'))
    {
        $body | Add-Member 'use_global_tm' ([int]$UseGlobalTM.ToBool())
    }
    if ($PSBoundParameters.ContainsKey('Logo'))
    {
        $body | Add-Member 'logo' $Logo
    }
    if ($PSBoundParameters.ContainsKey('DomainName'))
    {
        $body | Add-Member 'cname' $DomainName
    }
    if ($PSBoundParameters.ContainsKey('Description'))
    {
        $body | Add-Member 'description' $Description
    }
    if ($PSBoundParameters.ContainsKey('QAChecks'))
    {
        foreach ($qaCheck in $QAChecks.Keys)
        {
            $body | Add-Member "qa_checks[$qaCheck]" ([int]$QAChecks[$qaCheck])
        }
    }
    if ($PSBoundParameters.ContainsKey('WebhookFileTranslated'))
    {
        $body | Add-Member 'webhook_file_translated' $WebhookFileTranslated
    }
    if ($PSBoundParameters.ContainsKey('WebhookFileProofread'))
    {
        $body | Add-Member 'webhook_file_proofread' $WebhookFileProofread
    }
    if ($PSBoundParameters.ContainsKey('WebhookProjectTranslated'))
    {
        $body | Add-Member 'webhook_project_translated' $WebhookProjectTranslated
    }
    if ($PSBoundParameters.ContainsKey('WebhookProjectProofread'))
    {
        $body | Add-Member 'webhook_project_proofread' $WebhookProjectProofread
    }
    Invoke-ApiRequest -Url "project/$ProjectId/edit-project?json" -Body $body | Test-Response
}