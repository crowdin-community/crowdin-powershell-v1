function Get-AccountProject
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$AccountKey,

        [Parameter(Mandatory=$true)]
        [string]$Login
    )

    $body = [PSCustomObject]@{
        'account-key' = $AccountKey
    }
    $xml = Invoke-ApiRequest -Url "account/get-projects?login=$Login" -Body $body | Test-Response
    $xml.Success
}