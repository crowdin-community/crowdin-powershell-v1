$src = $MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent | Join-Path -ChildPath 'src'
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$src\$sut"

Describe "Resolve-File" {

    'file-a' | Set-Content TestDrive:/file-a.dat -NoNewline
    New-Item -Path TestDrive:/dir -ItemType Directory
    'file-b' | Set-Content TestDrive:/dir/file-b.dat -NoNewline
    'file-c' | Set-Content TestDrive:/file-c.dat -NoNewline

    $object = [PSCustomObject]@{
        'PropA' = 'ValueA'
        'Complex[Prop][Name]' = 'TestDrive:/file-a.dat'
        'IntProp' = 42
        'FileNameProp' = 'TestDrive:/dir/file-b.dat'
        'FileProp' = [System.IO.FileInfo](Get-Item -LiteralPath TestDrive:/file-c.dat)
    } | Resolve-File -FileProperty 'FileProp','WrongNameA','FileNameProp','Complex[Prop][Name]','WrongNameB'

    It "does not change number of properties" {
        $object.PSObject.Properties | Should -HaveCount 5
    }

    It "does not touch unlisted properties" {
        $object.PropA | Should -BeExactly 'ValueA'
        $object.IntProp | Should -BeExactly 42
    }

    It "resolves file names to FileInfo instances" {
        $object.'Complex[Prop][Name]' | Should -BeOfType [System.IO.FileInfo]
        $object.'Complex[Prop][Name]'.FullName | Should -BeExactly (Join-Path $TestDrive 'file-a.dat')
        $object.'Complex[Prop][Name]'.FullName | Should -FileContentMatchExactly 'file-a'
        $object.FileNameProp | Should -BeOfType [System.IO.FileInfo]
        $object.FileNameProp.FullName | Should -BeExactly (Join-Path $TestDrive 'dir/file-b.dat')
        $object.FileNameProp.FullName | Should -FileContentMatchExactly 'file-b'
    }

    It "does not touch existed FileInfo instances" {
        $object.FileProp | Should -BeOfType [System.IO.FileInfo]
        $object.FileProp.FullName | Should -BeExactly (Join-Path $TestDrive 'file-c.dat')
        $object.FileProp.FullName | Should -FileContentMatchExactly 'file-c'
    }
}