function Format-RequestBody
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]$InputObject
    )

    begin {
        function Format-Member($MemberName, $MemberValue) {
            $values = Format-Value $MemberValue
            $members = [ordered]@{}
            foreach ($key in $values.Keys)
            {
                $members.Add("$MemberName$($key)", $values[$key])
            }
            $members
        }

        function Format-Value($Value) {
            function Format-Switch {
                @{ '' = ([int]$Value.ToBool()) }
            }

            function Format-Boolean {
                @{ '' = ([int]$Value) }
            }

            function Format-DateTime {
                @{ '' = Get-Date -Date $Value -Format s }
            }

            function Format-Array {
                $members = [ordered]@{}
                for ($i = 0; $i -lt $Value.Length; $i++)
                {
                    $values = Format-Member "[$i]" $Value[$i]
                    foreach ($subKey in $values.Keys)
                    {
                        $members.Add($subKey, $values[$subKey])
                    }
                }
                $members
            }

            function Format-Hashtable {
                $members = [ordered]@{}
                foreach ($key in $Value.Keys)
                {
                    $values = Format-Member "[$key]" $Value[$key]
                    foreach ($subKey in $values.Keys)
                    {
                        $members.Add($subKey, $values[$subKey])
                    }
                }
                $members
            }

            function Format-Object {
                $members = [ordered]@{}
                foreach ($member in ($Value | Get-Member -MemberType NoteProperty))
                {
                    $values = Format-Member "[$($member.Name)]" $Value.($member.Name)
                    foreach ($subKey in $values.Keys)
                    {
                        $members.Add($subKey, $values[$subKey])
                    }
                }
                $members
            }

            if ($Value -is [System.Management.Automation.SwitchParameter]) {
                Format-Switch
            }
            elseif ($Value -is [bool]) {
                Format-Boolean
            }
            elseif ($Value -is [System.DateTime]) {
                Format-DateTime
            }
            elseif ($Value -is [array]) {
                Format-Array
            }
            elseif ($Value -is [hashtable]) {
                Format-Hashtable
            }
            elseif ($Value -is [System.Collections.Specialized.OrderedDictionary]) {
                Format-Hashtable
            }
            elseif ($Value -is [psobject]) {
                Format-Object
            }
            else {
                @{ '' = $Value }
            }
        }
    }

    process {
        $requestBody = [PSCustomObject]@{}
        foreach ($member in ($InputObject.PSObject.Properties | Where-Object -Property MemberType -EQ NoteProperty))
        {
            $members = Format-Member -MemberName $member.Name.ToLower() -MemberValue ($member.Value)
            $requestBody | Add-Member -NotePropertyMembers $members
        }
        $requestBody
    }
}
