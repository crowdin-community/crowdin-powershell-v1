function Save-TranslationMemory
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [Alias('key')]
        [string]$ProjectKey,

        [Parameter()]
        [Alias('include_assigned')]
        [switch]$IncludeAssigned,

        [Parameter()]
        [Alias('source_language')]
        [string]$SourceLanguage,

        [Parameter()]
        [Alias('target_language')]
        [string]$TargetLanguage,

        [Parameter()]
        [string]$OutDir = (Get-Location)
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId,OutDir
    Invoke-ApiRequest -Url "project/$ProjectId/download-tm?json" -Body $body -OutDir $OutDir
}