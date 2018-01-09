New-Variable ApiBaseUrl -Value ([uri]'https://api.crowdin.com/api/') -Option Constant
New-Variable HttpClient -Value (New-Object System.Net.Http.HttpClient -Property @{BaseAddress=$ApiBaseUrl}) -Option Constant

function Invoke-ApiRequest
{
    [CmdletBinding(DefaultParameterSetName='GET')]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory, Position=0)]
        [uri]$Url,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName='POST')]
        [psobject]$Body
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'GET')
        {
            $response = $HttpClient.GetAsync($Url).GetAwaiter().GetResult()
        }
        else
        {
            $content = New-Object System.Net.Http.MultipartFormDataContent
            foreach ($member in ($Body | Get-Member -MemberType Properties))
            {
                $partName = $member.Name
                $partValue = $Body.($member.Name)
                if ($partValue -is [System.IO.FileInfo])
                {
                    $contentPart = New-Object System.Net.Http.StreamContent -ArgumentList ($partValue.OpenRead())
                    $content.Add($contentPart, $partName, $partValue.Name)
                }
                else
                {
                    $contentPart = New-Object System.Net.Http.StringContent -ArgumentList $partValue
                    $content.Add($contentPart, $partName)
                }
            }
            $response = $HttpClient.PostAsync($Url, $content).GetAwaiter().GetResult()
            $content.Dispose()
        }
        $json = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
        ConvertFrom-Json -InputObject $json
    }
}

function New-RequestBody
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Management.Automation.PSCmdlet]$Command,

        [Parameter()]
        [string[]]$ExcludeParameter
    )

    process {
        $requestBody = [PSCustomObject]@{}
        $myInvocation = $Command.MyInvocation
        foreach ($boundParameterName in $myInvocation.BoundParameters.Keys)
        {
            if (($boundParameterName -in $ExcludeParameter) -or
                ($boundParameterName -in [System.Management.Automation.Cmdlet]::CommonParameters) -or
                ($boundParameterName -in [System.Management.Automation.Cmdlet]::OptionalCommonParameters))
            {
                continue
            }
            $parameter = $myInvocation.MyCommand.Parameters[$boundParameterName]
            $parameterAliases = $parameter.Aliases
            $requestParameterName = if ($parameterAliases) { $parameterAliases[0] } else { $boundParameterName }
            $boundParameterValue = $myInvocation.BoundParameters[$boundParameterName]
            if ($boundParameterValue -is [System.Management.Automation.SwitchParameter])
            {
                $boundParameterValue = ([int]$boundParameterValue.ToBool())
            }
            elseif ($boundParameterValue -is [System.DateTime])
            {
                $boundParameterValue = Get-Date -Date $boundParameterValue -Format s
            }
            $requestBody | Add-Member $requestParameterName.ToLower()  $boundParameterValue
        }
        $requestBody
    }
}

function Test-Response
{
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline)]
        $Response
    )
    process {
        if ((Get-Member -InputObject $Response -Name 'Error' -MemberType NoteProperty) -and (-not $Response.Success))
        {
            throw $Response.Error
        }
        $Response
    }
}

$ExecutionContext.SessionState.Module.OnRemove = {
    Clear-Variable -Name HttpClient
}
