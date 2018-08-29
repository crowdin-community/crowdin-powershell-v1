Add-Type -AssemblyName System.Net.Http

$src = $MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent | Join-Path -ChildPath 'src'
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$src\$sut"

Describe "ConvertTo-MultipartFormDataContent" {
    $testFileName = 'test-file.txt'
    $testFileContent = "Some test content." | Set-Content "TestDrive:\$testFileName" -NoNewline -PassThru

    $object = [PSCustomObject]@{
        String = 'string value'
        Integer = 1906
        File = Join-Path $TestDrive $testFileName | Get-Item
    }
    $content = ConvertTo-MultipartFormDataContent -Object $object

    It "returns result of [System.Net.Http.MultipartFormDataContent] type" {
        ,$content | Should -BeOfType [System.Net.Http.MultipartFormDataContent]
    }

    Context "for [FileInfo] properties" {
        $fileContent = $content | Where-Object {$_.Headers.ContentDisposition.Name -eq 'File'}
        It "creates [StreamContent]" {
            $fileContent | Should -BeOfType [System.Net.Http.StreamContent]
        }
        It "with proper content" {
            $fileContent.ReadAsStringAsync().GetAwaiter().GetResult() | Should -BeExactly $testFileContent
        }
    }

    Context "for other properties" {
        $contentParts = $content | Where-Object {$_.Headers.ContentDisposition.Name -ne 'File'}
        It "creates [StringContent]" {
            $contentParts | Should -BeOfType [System.Net.Http.StringContent]
        }
        $expectedValues = $contentParts | ForEach-Object {
            @{
                Name = $_.Headers.ContentDisposition.Name
                ContentPart = $_
                ExpectedValue = $object.($_.Headers.ContentDisposition.Name)
            }
        }
        It "with proper content of <Name>" -TestCases $expectedValues {
            param ($Name, $ContentPart, $ExpectedValue)
            $ContentPart.ReadAsStringAsync().GetAwaiter().GetResult() | Should -BeExactly $ExpectedValue
        }
    }

    $content.Dispose()
}
