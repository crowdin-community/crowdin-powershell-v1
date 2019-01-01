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

            function Format-Single {
                @{ '' = ([single]$Value).ToString([cultureinfo]::InvariantCulture) }
            }

            function Format-Double {
                @{ '' = ([double]$Value).ToString([cultureinfo]::InvariantCulture) }
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
                foreach ($member in $Value.PSObject.Properties)
                {
                    $values = Format-Member "[$($member.Name)]" $member.Value
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
            elseif ($Value -is [single]) {
                Format-Single
            }
            elseif ($Value -is [double]) {
                Format-Double
            }
            elseif ($Value -is [decimal]) {
                Format-Double
            }
            elseif ($Value -is [System.DateTime]) {
                Format-DateTime
            }
            elseif ($Value -is [array]) {
                Format-Array
            }
            elseif ($Value -is [System.Collections.IDictionary]) {
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
        foreach ($member in $InputObject.PSObject.Properties)
        {
            $members = Format-Member -MemberName $member.Name.ToLower() -MemberValue $member.Value
            $requestBody | Add-Member -NotePropertyMembers $members
        }
        $requestBody
    }
}
