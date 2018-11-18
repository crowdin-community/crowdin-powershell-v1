function Update-File
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('identifier')]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('key')]
        [string]$ProjectKey,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        $File,

        [Parameter()]
        [string]$Title,

        [Parameter()]
        [string]$ExportPattern,

        [Parameter()]
        [string]$NewName,

        [Parameter()]
        [Alias('first_line_contains_header')]
        [switch]$FirstLineContainsHeader,

        [Parameter()]
        [string]$Scheme,

        [Parameter()]
        [Alias('update_option')]
        [ValidateSet('update_as_unapproved', 'update_without_changes')]
        [string]$UpdateOption,

        [Parameter()]
        [string]$Branch,

        [Parameter()]
        [Alias('escape_quotes')]
        [ValidateRange(0, 3)]
        [int]$EscapeQuotes
    )

    $ProjectId = [Uri]::EscapeDataString($ProjectId)
    $body = [pscustomobject]@{
        'key' = $ProjectKey
        "files[$Name]" = $File
    }
    if ($PSBoundParameters.ContainsKey('Title'))
    {
        $body | Add-Member "titles[$Name]" $Title
    }
    if ($PSBoundParameters.ContainsKey('ExportPattern'))
    {
        $body | Add-Member "export_patterns[$Name]" $ExportPattern
    }
    if ($PSBoundParameters.ContainsKey('NewName'))
    {
        $body | Add-Member "new_names[$Name]" $NewName
    }
    $body = $PSCmdlet |
        ConvertFrom-PSCmdlet -TargetObject $body -ExcludeParameter ProjectId,ProjectKey,Name,File,Title,ExportPattern,NewName |
        Resolve-File -FileProperty "files[$Name]"
    Invoke-ApiRequest -Url "project/$ProjectId/update-file?json" -Body $body
}