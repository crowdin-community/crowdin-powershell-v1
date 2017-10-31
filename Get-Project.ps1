function Get-Project
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$ProjectKey,

        [Parameter(Mandatory=$true)]
        [string]$ProjectId
    )

    $body = [PSCustomObject]@{
        'key' = $ProjectKey
    }
    $xml = Invoke-ApiRequest -Url "project/$ProjectId/info" -Body $body | Test-Response
    $xml.Info
}