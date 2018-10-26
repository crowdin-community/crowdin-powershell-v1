# crowdin-powershell
PowerShell module for Crowdin API is compatible with Windows PowerShell v4+ and [PowerShell Core](https://github.com/PowerShell/PowerShell#get-powershell).

## Available Cmdlets
List of available cmdlets and corresponding Crowdin API endpoints:

Cmdlet | API
------ | ---
`Get-SupportedLanguage` | [Supported Languages](https://support.crowdin.com/api/supported-languages/)
`Get-AccountProject` | [Account Projects](https://support.crowdin.com/api/get-projects/)
`New-Project` | [Create Project](https://support.crowdin.com/api/create-project/)
`Get-Project` | [Project Details](https://support.crowdin.com/api/info/)
`Edit-Project` | [Edit Project](https://support.crowdin.com/api/edit-project/)
`Remove-Project` | [Delete Project](https://support.crowdin.com/api/delete-project/)
`Measure-Project` | [Translation Status](https://support.crowdin.com/api/status/)
`Measure-Language` | [Language Status](https://support.crowdin.com/api/language-status/)
`Add-File` | [Add File](https://support.crowdin.com/api/add-file/)
`Update-File` | [Update File](https://support.crowdin.com/api/update-file/)
`Remove-File` | [Delete File](https://support.crowdin.com/api/delete-file/)
`Save-File` | [Export File](https://support.crowdin.com/api/export-file/)
`New-Folder` | [Add Directory](https://support.crowdin.com/api/add-directory/)
`Edit-Folder` | [Change Directory](https://support.crowdin.com/api/change-directory/)
`Remove-Folder` | [Delete Directory](https://support.crowdin.com/api/delete-directory/)
`Add-Glossary` | [Upload Glossary](https://support.crowdin.com/api/upload-glossary/)
`Save-Glossary` | [Download Glossary](https://support.crowdin.com/api/download-glossary/)
`Add-TranslationMemory` | [Upload TM](https://support.crowdin.com/api/upload-tm/)
`Save-TranslationMemory` | [Download TM](https://support.crowdin.com/api/download-tm/)
`Invoke-Pretranslation` | [Pre-Translate](https://support.crowdin.com/api/pre-translate/)
`Add-Translation` | [Upload Translation](https://support.crowdin.com/api/upload-translation/)
`Export-Translation` | [Export Translations](https://support.crowdin.com/api/export/)
`Save-Translation` | [Download Translations](https://support.crowdin.com/api/download/)
`Export-Pseudotranslation` | [Pseudo Export](https://support.crowdin.com/api/pseudo-export/)
`Save-Pseudotranslation` | [Pseudo Download](https://support.crowdin.com/api/pseudo-download/)
`Get-Issue` | [Reported Issues](https://support.crowdin.com/api/issues/)
`Export-CostsEstimationReport` | [Export Costs Estimation Report](https://support.crowdin.com/api/export-costs-estimation-report/)
`Save-CostsEstimationReport` | [Download Costs Estimation Report](https://support.crowdin.com/api/download-costs-estimation-report/)
`Export-TranslationCostsReport` | [Export Translation Costs Report](https://support.crowdin.com/api/export-translation-costs-report/)
`Save-TranslationCostsReport` | [Download Translation Costs Report](https://support.crowdin.com/api/download-translation-costs-report/)
`Export-TopMembersReport` | [Export Top Members Report](https://support.crowdin.com/api/export-top-members-report/)
`Save-TopMembersReport` | [Download Top Members Report](https://support.crowdin.com/api/download-top-members-report/)

Default command prefix is `Crowdin`, so add it before cmdlets noun or specify your own prefix when importing the module.
