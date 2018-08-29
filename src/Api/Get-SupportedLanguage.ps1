<#
.SYNOPSIS
Get supported languages.

.DESCRIPTION
Get supported languages list with Crowdin codes mapped to locale name and standardized codes.

.EXAMPLE
PS C:\> Get-CrowdinSupportedLanguage | Where-Object {$_.Name -like 'uk*'}

name         : Ukrainian
crowdin_code : uk
editor_code  : uk
iso_639_1    : uk
iso_639_3    : ukr
locale       : uk-UA
android_code : uk-rUA
osx_locale   : uk

#>
function Get-SupportedLanguage
{
    [CmdletBinding()]
    param ()

    Invoke-ApiRequest -Url 'supported-languages?json'
}