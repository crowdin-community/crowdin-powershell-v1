function Save-Pseudotranslation
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
        [string]$OutDir = (Get-Location)
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId,OutDir
    Invoke-ApiRequest -Url "project/$ProjectId/pseudo-download?json" -Body $body -OutDir $OutDir
}