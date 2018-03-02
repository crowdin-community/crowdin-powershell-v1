$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

function Test-ConvertFromPSCmdlet {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()]
        [string]$StringParam,
        [Parameter()]
        [int]$IntParam,
        [Parameter()]
        [bool]$BoolParam,
        [Parameter()]
        [switch]$SwitchParam,
        [Parameter()]
        [datetime]$DateTimeParam,
        [Parameter()]
        [Alias('AliasedParam')]
        $NamedParam,
        [Parameter()]
        [string[]]$ExcludeParameter
    )
    $PSCmdlet | ConvertFrom-PSCmdlet -ExcludeParameter (,'ExcludeParameter' + $ExcludeParameter)
}

Describe "ConvertFrom-PSCmdlet" {

    $object = Test-ConvertFromPSCmdlet
    It "returns result of [PSCustomObject] type" {
        $object | Should -BeOfType [PSCustomObject]
    }

    Context "without parameters" {
        $object = Test-ConvertFromPSCmdlet
        It "returns empty object" {
            ($object | Get-Member -MemberType NoteProperty) | Should -BeNullOrEmpty
        }
    }

    Context "with parameters" {
        $params = @{
            StringParam = 'a'
            IntParam = 7
            BoolParam = $true
            DateTimeParam = Get-Date -Year 1987 -Month 6 -Day 19 -Hour 16 -Minute 7 -Second 0
            NamedParam = 'name'
        }
        $object = Test-ConvertFromPSCmdlet @params
        It "generates expected number of properties" {
            ($object | Get-Member -MemberType NoteProperty).Length | Should -Be $params.Count
        }
        It "keeps type of boolean values" {
            $object.BoolParam | Should -BeOfType [bool]
        }
        It "formats date-time to ISO-8601 string" {
            $object.DateTimeParam | Should -BeExactly '1987-06-19T16:07:00'
        }
        It "respects parameter aliases" {
            $object.AliasedParam | Should -BeExactly 'name'
        }
    }

    Context "for switch parameters" {
        $object = Test-ConvertFromPSCmdlet
        It "does not generate property if switch is omitted" {
            $object | Get-Member -MemberType NoteProperty -Name SwitchParam | Should -BeNullOrEmpty
        }
        Context "generate property if switch is specified" {
            $object = Test-ConvertFromPSCmdlet -SwitchParam
            It "'1' for turned on" {
                $object.SwitchParam | Should -BeExactly 1
            }
            $object = Test-ConvertFromPSCmdlet -SwitchParam:$false
            It "'0' for turned off" {
                $object.SwitchParam | Should -BeExactly 0
            }
        }
    }

    Context "exclude parameters" {
        $object = Test-ConvertFromPSCmdlet -Debug -ErrorAction Stop -ErrorVariable ev -Verbose -WhatIf
        It "does not generate properties for common parameters" {
            $object | Get-Member -MemberType NoteProperty | Should -BeNullOrEmpty
        }
        $object = Test-ConvertFromPSCmdlet -StringParam 'a' -IntParam 7 -DateTimeParam (Get-Date) -ExcludeParameter DateTimeParam,StringParam
        $members = $object | Get-Member -MemberType NoteProperty
        It "does not generate properties for excluded parameters" {
             $members.Length | Should -BeExactly 1
             $members[0].Name | Should -BeExactly IntParam
        }
    }
}