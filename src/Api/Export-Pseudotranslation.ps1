function Export-Pseudotranslation
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
        [string]$Prefix,

        [Parameter()]
        [string]$Suffix,

        [Parameter()]
        [Alias('length_transformation')]
        [ValidateRange(-50, 100)]
        [int]$LengthTransformation,

        [Parameter()]
        [Alias('char_transformation')]
        [ValidateSet('asian', 'european', 'arabic')]
        [string]$CharTransformation
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId
    Invoke-ApiRequest -Url "project/$ProjectId/pseudo-export?json" -Body $body
}