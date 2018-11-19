function Export-Pseudotranslation
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('key')]
        [string]$ProjectKey,

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