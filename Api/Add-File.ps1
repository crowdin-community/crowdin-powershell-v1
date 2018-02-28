function Add-File
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('key')]
        [string]$ProjectKey,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('identifier')]
        [string]$ProjectId,

        [Parameter(Mandatory)]
        [string]$FileName,

        [Parameter(Mandatory)]
        [System.IO.FileInfo]$File,

        [Parameter()]
        [string]$Title,

        [Parameter()]
        [string]$ExportPattern,

        [Parameter()]
        [string]$Type,

        [Parameter()]
        [Alias('first_line_contains_header')]
        [switch]$FirstLineContainsHeader,

        [Parameter()]
        [string]$Scheme,
        
        [Parameter()]
        [string]$Branch
    )

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
    if ($PSBoundParameters.ContainsKey('Type'))
    {
        $body | Add-Member 'type' $Type
    }
    if ($FirstLineContainsHeader)
    {
        $body | Add-Member 'first_line_contains_header' ([int]$FirstLineContainsHeader.ToBool())
    }
    if ($PSBoundParameters.ContainsKey('Scheme'))
    {
        $body | Add-Member 'scheme' $Scheme
    }
    if ($PSBoundParameters.ContainsKey('Branch'))
    {
        $body | Add-Member 'branch' $Branch
    }
    Invoke-ApiRequest -Url "project/$ProjectId/add-file?json" -Body $body | Test-Response
}