function Save-TranslationMemory
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