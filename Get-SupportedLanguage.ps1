function Get-SupportedLanguage
{
    [CmdletBinding()]
    param ()

    Invoke-ApiRequest -Url 'supported-languages?json' | Test-Response
}