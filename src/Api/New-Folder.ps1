function New-Folder
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('key')]
        [string]$ProjectKey,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [string]$Title,

        [Parameter()]
        [Alias('export_pattern')]
        [string]$ExportPattern,

        [Parameter()]
        [switch]$Recursive,

        [Parameter()]
        [switch]$IsBranch,

        [Parameter()]
        [string]$Branch
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId
    Invoke-ApiRequest -Url "project/$ProjectId/add-directory?json" -Body $body
}