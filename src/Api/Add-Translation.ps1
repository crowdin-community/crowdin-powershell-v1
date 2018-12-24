function Add-Translation
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
        [string]$FileName,

        [Parameter(Mandatory)]
        $File,

        [Parameter(Mandatory)]
        [string]$Language,

        [Parameter()]
        [Alias('import_duplicates')]
        [switch]$ImportDuplicates,

        [Parameter()]
        [Alias('import_eq_suggestions')]
        [switch]$ImportEqualSuggestions,

        [Parameter()]
        [Alias('auto_approve_imported')]
        [switch]$AutoApproveImported,

        [Parameter()]
        [string]$Format,

        [Parameter()]
        [string]$Branch
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = [pscustomobject]@{
        "files[$FileName]" = $File
    }
    $body = $PSCmdlet |
        ConvertFrom-PSCmdlet -TargetObject $body -ExcludeParameter ProjectId,FileName,File |
        Resolve-File -FileProperty "files[$FileName]"
    Invoke-ApiRequest -Url "project/$ProjectId/upload-translation?json" -Body $body
}