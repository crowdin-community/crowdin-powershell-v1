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
            $requestBody | Add-Member -NotePropertyName $requestParameterName -NotePropertyValue $boundParameterValue
        }
        $requestBody
    }
}
