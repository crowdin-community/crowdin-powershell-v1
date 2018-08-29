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
        [string]$FileName,

        [Parameter(Mandatory)]
        [System.IO.FileInfo]$File,

        [Parameter()]
        [string]$Title,

        [Parameter()]
        [string]$ExportPattern,

        [Parameter()]
        [string]$NewFileName,

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
        "files[$FileName]" = $File
    }
    if ($PSBoundParameters.ContainsKey('Title'))
    {
        $body | Add-Member "titles[$FileName]" $Title
    }
    if ($PSBoundParameters.ContainsKey('ExportPattern'))
    {
        $body | Add-Member "export_patterns[$FileName]" $ExportPattern
    }
    if ($PSBoundParameters.ContainsKey('NewFileName'))
    {
        $body | Add-Member "new_names[$FileName]" $NewFileName
    }
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -TargetObject $body -ExcludeParameter ProjectId,ProjectKey,FileName,File,Title,ExportPattern,NewFileName
    Invoke-ApiRequest -Url "project/$ProjectId/update-file?json" -Body $body
}