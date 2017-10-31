function Get-SupportedLanguage
{
    [CmdletBinding()]
    param ()

    $xml = Invoke-ApiRequest -Url 'supported-languages' | Test-Response
    $xml.Languages
}