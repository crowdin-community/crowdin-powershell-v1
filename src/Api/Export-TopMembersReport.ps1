function Export-TopMembersReport
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias('identifier')]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [Alias('key')]
        [string]$ProjectKey,

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

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId
    Invoke-ApiRequest -Url "project/$ProjectId/reports/top-members/export?json" -Body $body
}