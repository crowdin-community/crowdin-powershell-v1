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
    $response = Invoke-ApiRequest -Url "account/get-projects?json&login=$Login" -Body $body | Test-Response
    $response.Projects
}