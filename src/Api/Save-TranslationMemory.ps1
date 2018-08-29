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
        [switch]$SourceLanguage,

        [Parameter()]
        [Alias('target_language')]
        [switch]$TargetLanguage,

        [Parameter()]
        [string]$OutDir = (Get-Location)
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId
    $response = Invoke-ApiRequest -Url "project/$ProjectId/download-tm?json" -Body $body -OutDir $OutDir
    $response.File
}