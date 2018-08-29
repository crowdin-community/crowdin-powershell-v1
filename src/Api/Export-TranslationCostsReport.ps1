function Export-TranslationCostsReport
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('identifier')]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('key')]
        [string]$ProjectKey,

        [Parameter()]
        [ValidateSet('strings', 'words', 'chars', 'chars_with_spaces')]
        [string]$Unit,

        [Parameter()]
        [ValidateSet('simple', 'fuzzy')]
        [string]$Mode,

        [Parameter()]
        [Alias('date_from')]
        [datetime]$DateFrom,

        [Parameter()]
        [Alias('date_to')]
        [datetime]$DateTo,

        [Parameter()]
        [Alias('regular_rates')]
        [hashtable]$RegularRates,

        [Parameter()]
        [Alias('individual_rates')]
        [hashtable[]]$IndividualRates,

        [Parameter()]
        [string]$Currency,

        [Parameter()]
        [ValidateSet('csv', 'xslx')]
        [string]$Format,

        [Parameter()]
        [Alias('role_based_costs')]
        [switch]$RoleBased,

        [Parameter()]
        [ValidateSet('user', 'language')]
        [Alias('group_by')]
        [string]$GroupBy
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId
    $response = Invoke-ApiRequest -Url "project/$ProjectId/reports/translation-costs/export?json" -Body $body
    $response.Hash
}