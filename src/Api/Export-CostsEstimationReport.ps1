function Export-CostsEstimationReport
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

        [Parameter(Mandatory)]
        [string]$Language,

        [Parameter()]
        [ValidateSet('strings', 'words', 'chars', 'chars_with_spaces')]
        [string]$Unit,

        [Parameter()]
        [ValidateSet('simple', 'fuzzy')]
        [string]$Mode,

        [Parameter()]
        [Alias('calculate_internal_fuzzy_matches')]
        [switch]$CalculateInternalFuzzyMatches,

        [Parameter()]
        [Alias('date_from')]
        [datetime]$DateFrom,

        [Parameter()]
        [Alias('date_to')]
        [datetime]$DateTo,

        [Parameter()]
        [Alias('regular_rates')]
        [ValidateScript({
            $_ -is [psobject] -or $_ -is [System.Collections.IDictionary]
        })]
        $RegularRates,

        [Parameter()]
        [Alias('individual_rates')]
        [ValidateScript({
            [array]::TrueForAll([object[]]$_, [Predicate[object]]{ param($obj)
                $obj -is [psobject] -or $obj -is [System.Collections.IDictionary]
            })
        })]
        [array]$IndividualRates,

        [Parameter()]
        [string]$Currency,

        [Parameter()]
        [ValidateSet('csv', 'xslx')]
        [string]$Format
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId
    Invoke-ApiRequest -Url "project/$ProjectId/reports/costs-estimation/export?json" -Body $body
}