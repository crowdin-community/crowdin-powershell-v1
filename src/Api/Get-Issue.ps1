function Get-Issue
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
        [string]$Type,

        [Parameter()]
        [string]$Status,

        [Parameter()]
        [string]$File,

        [Parameter()]
        [string]$Language,

        [Parameter()]
        [Alias('date_from')]
        [datetime]$DateFrom,

        [Parameter()]
        [Alias('date_to')]
        [datetime]$DateTo
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId
    Invoke-ApiRequest -Url "project/$ProjectId/issues?json" -Body $body
}