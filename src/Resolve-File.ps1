function Resolve-File
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSObject]$InputObject,

        [Parameter()]
        [string[]]$FileProperty
    )

    process {
        foreach ($propertyName in $FileProperty)
        {
            if ($InputObject.$propertyName -and $InputObject.$propertyName -isnot [System.IO.FileInfo])
            {
                $InputObject.$propertyName = [System.IO.FileInfo](Get-Item $InputObject.$propertyName)
            }
        }
        $InputObject
    }
}
