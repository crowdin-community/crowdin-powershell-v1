function ConvertFrom-PSCmdlet
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Management.Automation.PSCmdlet]$Command,

        [Parameter()]
        [ValidateNotNull()]
        [PSCustomObject]$TargetObject = [PSCustomObject]@{},

        [Parameter()]
        [string[]]$ExcludeParameter
    )

    process {
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
            $targetName = if ($parameterAliases) { $parameterAliases[0] } else { $boundParameterName }
            $targetValue = $myInvocation.BoundParameters[$boundParameterName]

            $TargetObject | Add-Member -NotePropertyName $targetName -NotePropertyValue $targetValue
        }
        $TargetObject
    }
}
