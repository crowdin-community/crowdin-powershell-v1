function ConvertFrom-PSCmdlet
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Management.Automation.PSCmdlet]$Command,

        [Parameter()]
        [string[]]$ExcludeParameter
    )

    begin {
        function Expand-Parameter($ParameterName, $ParameterValue) {
            function Expand-Switch {
                @{ $ParameterName = ([int]$ParameterValue.ToBool()) }
            }

            function Expand-DateTime {
                @{ $ParameterName = Get-Date -Date $ParameterValue -Format s }
            }

            function Expand-Array {
                $members = [ordered]@{}
                for ($i = 0; $i -lt $ParameterValue.Length; $i++)
                {
                    $members.Add("$ParameterName[$i]", $ParameterValue[$i])
                }
                $members
            }

            function Expand-Hashtable {
                $members = [ordered]@{}
                foreach ($key in $ParameterValue.Keys)
                {
                    $members.Add("$ParameterName[$key]", $ParameterValue[$key])
                }
                $members
            }

            $ParameterName = $ParameterName.ToLower()
            if ($ParameterValue -is [System.Management.Automation.SwitchParameter]) { Expand-Switch }
            elseif ($ParameterValue -is [System.DateTime]) { Expand-DateTime }
            elseif ($ParameterValue -is [array]) { Expand-Array }
            elseif ($ParameterValue -is [hashtable]) { Expand-Hashtable }
            else { @{ $ParameterName = $ParameterValue } }
        }
    }

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

            $requestBody | Add-Member -NotePropertyMembers (Expand-Parameter $requestParameterName $boundParameterValue)
        }
        $requestBody
    }
}
