function Save-CostsEstimationReport
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

        [Parameter(Mandatory)]
        [string]$Hash,

        [Parameter()]
        [string]$OutDir = (Get-Location)
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $ProjectKey = [Uri]::EscapeDataString($ProjectKey)
    $Hash = [Uri]::EscapeDataString($Hash)
    Invoke-ApiRequest -Url "project/$ProjectId/reports/costs-estimation/download?json&key=$ProjectKey&hash=$Hash" -OutDir $OutDir
}