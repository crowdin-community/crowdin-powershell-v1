function Save-File
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [Alias('key')]
        [string]$ProjectKey,

        [Parameter(Mandatory)]
        [string]$File,

        [Parameter(Mandatory)]
        [string]$Language,

        [Parameter()]
        [string]$Branch,

        [Parameter()]
        [string]$Format,

        [Parameter()]
        [Alias('export_translated_only')]
        [switch]$TranslatedOnly,

        [Parameter()]
        [Alias('export_approved_only')]
        [switch]$ApprovedOnly,

        [Parameter()]
        [string]$OutDir = (Get-Location),

        [Parameter()]
        [string]$EntityTag
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId,OutDir,EntityTag
    Invoke-ApiRequest -Url "project/$ProjectId/export-file?json" -Body $body -OutDir $OutDir -EntityTag $EntityTag
}