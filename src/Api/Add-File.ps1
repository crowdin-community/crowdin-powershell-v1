function Add-File
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
        [Alias('import_translations')]
        [switch]$ImportTranslations,

        [Parameter()]
        [string]$Scheme,

        [Parameter()]
        [string]$Branch,

        [Parameter()]
        [Alias('translate_content')]
        [switch]$TranslateContent,

        [Parameter()]
        [Alias('translate_attributes')]
        [switch]$TranslateAttributes,

        [Parameter()]
        [Alias('content_segmentation')]
        [switch]$ContentSegmentation,

        [Parameter()]
        [Alias('translatable_elements')]
        [string[]]$TranslatableElements,

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
    $body = $PSCmdlet | ConvertFrom-PSCmdlet -TargetObject $body -ExcludeParameter ProjectId,ProjectKey,Name,File,Title,ExportPattern
    Invoke-ApiRequest -Url "project/$ProjectId/add-file?json" -Body $body
}