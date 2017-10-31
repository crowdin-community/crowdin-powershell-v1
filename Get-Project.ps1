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
    Invoke-ApiRequest -Url "project/$ProjectId/info?json" -Body $body | Test-Response
}