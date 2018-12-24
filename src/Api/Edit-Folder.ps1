function Edit-Folder
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [Alias('key')]
        [string]$ProjectKey,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [Alias('new_name')]
        [string]$NewName,

        [Parameter()]
        [string]$Title,

        [Parameter()]
        [Alias('export_pattern')]
        [string]$ExportPattern,

        [Parameter()]
        [string]$Branch
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId
    Invoke-ApiRequest -Url "project/$ProjectId/change-directory?json" -Body $body
}