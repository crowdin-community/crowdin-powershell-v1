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
        $commandInvocation = $Command.MyInvocation
        foreach ($boundParameterName in $commandInvocation.BoundParameters.Keys)
        {
            if (($boundParameterName -in $ExcludeParameter) -or
                ($boundParameterName -in [System.Management.Automation.Cmdlet]::CommonParameters) -or
                ($boundParameterName -in [System.Management.Automation.Cmdlet]::OptionalCommonParameters))
            {
                continue
            }
            $parameter = $commandInvocation.MyCommand.Parameters[$boundParameterName]
            $parameterAliases = $parameter.Aliases
            $targetName = if ($parameterAliases) { $parameterAliases[0] } else { $boundParameterName }
            $targetValue = $commandInvocation.BoundParameters[$boundParameterName]

            $TargetObject | Add-Member -NotePropertyName $targetName -NotePropertyValue $targetValue
        }
        $TargetObject
    }
}
