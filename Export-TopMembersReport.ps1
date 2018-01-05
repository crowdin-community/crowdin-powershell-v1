function Export-TopMembersReport
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
        [ValidateSet('strings', 'words', 'chars', 'chars_with_spaces')]
        [string]$Unit,

        [Parameter()]
        [string]$Language,

        [Parameter()]
        [Alias('date_from')]
        [datetime]$DateFrom,

        [Parameter()]
        [Alias('date_to')]
        [datetime]$DateTo,

        [Parameter()]
        [ValidateSet('csv', 'xslx')]
        [string]$Format
    )

    $body = [pscustomobject]@{
        'key' = $ProjectKey
    }
    if ($PSBoundParameters.ContainsKey('Unit'))
    {
        $body | Add-Member 'unit' $Unit
    }
    if ($PSBoundParameters.ContainsKey('Language'))
    {
        $body | Add-Member 'language' $Language
    }
    if ($PSBoundParameters.ContainsKey('DateFrom'))
    {
        $body | Add-Member 'date_from' (Get-Date -Date $DateFrom -Format s)
    }
    if ($PSBoundParameters.ContainsKey('DateTo'))
    {
        $body | Add-Member 'date_to' (Get-Date -Date $DateTo -Format s)
    }
    if ($PSBoundParameters.ContainsKey('Format'))
    {
        $body | Add-Member 'format' $Format
    }

    $response = Invoke-ApiRequest -Url "project/$ProjectId/reports/top-members/export?json" -Body $body | Test-Response
    $response.Hash
}