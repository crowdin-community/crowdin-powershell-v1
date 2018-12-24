function Add-Glossary
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
        $File,

        [Parameter()]
        [Alias('first_line_contains_header')]
        [switch]$FirstLineContainsHeader,

        [Parameter()]
        [string]$Scheme
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter ProjectId | Resolve-File -FileProperty File
    Invoke-ApiRequest -Url "project/$ProjectId/upload-glossary?json" -Body $body
}