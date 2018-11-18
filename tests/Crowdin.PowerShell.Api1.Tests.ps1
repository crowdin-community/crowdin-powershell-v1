$src = $MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent | Join-Path -ChildPath 'src'

Describe "Test API requests" {

    BeforeAll {
        $Global:moduleUnderTest = Import-Module "$src\Crowdin.PowerShell.Api1.psd1" -PassThru
    }

    AfterAll {
        Remove-Module -ModuleInfo $Global:moduleUnderTest
        Remove-Variable -Name moduleUnderTest -Scope Global
    }

    InModuleScope 'Crowdin.PowerShell.Api1' {

        Context "HttpClient" {

            It "Has valid default User-Agent header" {
                $ua = $HttpClient.DefaultRequestHeaders.UserAgent
                $ua.Product.Name | Should -BeExactly @($moduleUnderTest.Name, $PSVersionTable.PSEdition)
                $ua.Product.Version | Should -BeExactly @($moduleUnderTest.Version, $PSVersionTable.PSVersion)
            }
        }

        Context "Invoke-ApiRequest" {

            Mock -ModuleName 'Crowdin.PowerShell.Api1' -CommandName 'Send-ApiRequest' -MockWith {
                $responseContent = New-Object System.Net.Http.StringContent -ArgumentList @('{"success":true,"sentinel":"1N73LL1G3NC3"}')
                $responseContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('application/json')
                New-Object System.Net.Http.HttpResponseMessage -ArgumentList @([System.Net.HttpStatusCode]::NonAuthoritativeInformation) -Property @{
                    RequestMessage = $Request
                    ReasonPhrase = "Mock"
                    Content = $responseContent
                }
            } -ParameterFilter {
                $Request.RequestUri -eq [uri]'resource/success?json'
            }

            Mock -ModuleName 'Crowdin.PowerShell.Api1' -CommandName 'Send-ApiRequest' -MockWith {
                $responseContent = New-Object System.Net.Http.StringContent -ArgumentList @('PL41N 73X7')
                $responseContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('text/plain')
                New-Object System.Net.Http.HttpResponseMessage -ArgumentList @([System.Net.HttpStatusCode]::NonAuthoritativeInformation) -Property @{
                    RequestMessage = $Request
                    ReasonPhrase = "Mock"
                    Content = $responseContent
                }
            } -ParameterFilter {
                $Request.RequestUri -eq [uri]'resource/success?txt'
            }

            Mock -ModuleName 'Crowdin.PowerShell.Api1' -CommandName 'Send-ApiRequest' -MockWith {
                New-Object System.Net.Http.HttpResponseMessage -ArgumentList @([System.Net.HttpStatusCode]::NotModified) -Property @{
                    RequestMessage = $Request
                    ReasonPhrase = "Mock"
                }
            } -ParameterFilter {
                $Request.RequestUri -eq [uri]'resource/not-modified?json'
            }

            Mock -ModuleName 'Crowdin.PowerShell.Api1' -CommandName 'Send-ApiRequest' -MockWith {
                $responseContent = New-Object System.Net.Http.StringContent -ArgumentList @('{"success":true,"sentinel":"1N73LL1G3NC3"}')
                $responseContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('application/json')
                $response = New-Object System.Net.Http.HttpResponseMessage -ArgumentList @([System.Net.HttpStatusCode]::NonAuthoritativeInformation) -Property @{
                    RequestMessage = $Request
                    ReasonPhrase = "Mock"
                    Content = $responseContent
                }
                [void]$response.Headers.TryAddWithoutValidation('ETag', '4D4P7 70 CH4NG35')
                $response
            } -ParameterFilter {
                $Request.RequestUri -eq [uri]'resource/success/etag?json'
            }

            Mock -ModuleName 'Crowdin.PowerShell.Api1' -CommandName 'Send-ApiRequest' -MockWith {
                $response = New-Object System.Net.Http.HttpResponseMessage -ArgumentList @([System.Net.HttpStatusCode]::NotModified) -Property @{
                    RequestMessage = $Request
                    ReasonPhrase = "Mock"
                }
                [void]$response.Headers.TryAddWithoutValidation('ETag', '4D4P7 70 CH4NG35')
                $response
            } -ParameterFilter {
                $Request.RequestUri -eq [uri]'resource/not-modified/etag?json'
            }

            Mock -ModuleName 'Crowdin.PowerShell.Api1' -CommandName 'Send-ApiRequest' -MockWith {
                $responseContent = New-Object System.Net.Http.StringContent -ArgumentList @('F1L3 C0N73N7')
                $responseContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('text/plain')
                $responseContent.Headers.ContentDisposition = [System.Net.Http.Headers.ContentDispositionHeaderValue]::Parse('attachment; filename="dowloaded.txt"')
                New-Object System.Net.Http.HttpResponseMessage -ArgumentList @([System.Net.HttpStatusCode]::NonAuthoritativeInformation) -Property @{
                    RequestMessage = $Request
                    ReasonPhrase = "Mock"
                    Content = $responseContent
                }
            } -ParameterFilter {
                $Request.RequestUri -eq [uri]'resource/file'
            }

            It "send GET request if called without body" {
                $result = Invoke-ApiRequest -Url 'resource/success?json'
                Assert-MockCalled 'Send-ApiRequest' -Scope It -Times 1 -Exactly -ParameterFilter {
                    $Request.Method -eq [System.Net.Http.HttpMethod]::Get -and
                    $Request.RequestUri -eq [uri]'resource/success?json'
                }
                $result | Should -BeOfType [PSCustomObject]
                $result.Success | Should -BeTrue
                $result.Sentinel | Should -BeExactly '1N73LL1G3NC3'
            }

            It "send POST request if called with body" {
                $requestBody = [pscustomobject]@{ str = 'value'; int = 42; bool = $true }
                $result = Invoke-ApiRequest -Url 'resource/success?json' -Body $requestBody
                Assert-MockCalled 'Send-ApiRequest' -Scope It -Times 1 -Exactly -ParameterFilter {
                    $Request.Method -eq [System.Net.Http.HttpMethod]::Post -and
                    $Request.RequestUri -eq [uri]'resource/success?json'
                }
                $result | Should -BeOfType [PSCustomObject]
                $result.Success | Should -BeTrue
                $result.Sentinel | Should -BeExactly '1N73LL1G3NC3'
            }

            It "accepts only JSON response content" {
                { Invoke-ApiRequest -Url 'resource/success?txt' } | Should -Throw "Only JSON content is acceptable."
                Assert-MockCalled 'Send-ApiRequest' -Scope It -Times 1 -Exactly -ParameterFilter {
                    $Request.Method -eq [System.Net.Http.HttpMethod]::Get -and
                    $Request.RequestUri -eq [uri]'resource/success?txt'
                }
            }

            It "saves downloaded file to specified directory" {
                $result = Invoke-ApiRequest -Url 'resource/file' -OutDir $TestDrive
                Assert-MockCalled 'Send-ApiRequest' -Scope It -Times 1 -Exactly -ParameterFilter {
                    $Request.Method -eq [System.Net.Http.HttpMethod]::Get -and
                    $Request.RequestUri -eq [uri]'resource/file'
                }
                $result | Should -BeOfType [PSCustomObject]
                $result.Success | Should -BeTrue
                $result.File | Should -BeOfType [System.IO.FileInfo]
                $expectedFileName = "$TestDrive\dowloaded.txt"
                $result.File.FullName | Should -BeExactly $expectedFileName
                Get-Content -LiteralPath $expectedFileName -Raw | Should -BeExactly 'F1L3 C0N73N7'
            }

            Context "if called with -EntityTag, adds 'If-None-Match' header" {

                It "to GET request" {
                    $result = Invoke-ApiRequest -Url 'resource/success?json' -EntityTag '4B1L17Y'
                    Assert-MockCalled 'Send-ApiRequest' -Scope It -Times 1 -Exactly -ParameterFilter {
                        $ifNoneMatch = $null
                        $Request.Method -eq [System.Net.Http.HttpMethod]::Get -and
                        $Request.RequestUri -eq [uri]'resource/success?json' -and
                        $Request.Headers.TryGetValues('If-None-Match', [ref]$ifNoneMatch) -and
                        $ifNoneMatch[0] -eq '4B1L17Y'
                    }
                    $result | Should -BeOfType [PSCustomObject]
                    $result.Success | Should -BeTrue
                    $result.Sentinel | Should -BeExactly '1N73LL1G3NC3'
                }

                It "to POST request" {
                    $requestBody = [pscustomobject]@{ str = 'value'; int = 42; bool = $true }
                    $result = Invoke-ApiRequest -Url 'resource/success?json' -Body $requestBody -EntityTag '4B1L17Y'
                    Assert-MockCalled 'Send-ApiRequest' -Scope It -Times 1 -Exactly -ParameterFilter {
                        $ifNoneMatch = $null
                        $Request.Method -eq [System.Net.Http.HttpMethod]::Post -and
                        $Request.RequestUri -eq [uri]'resource/success?json' -and
                        $Request.Headers.TryGetValues('If-None-Match', [ref]$ifNoneMatch) -and
                        $ifNoneMatch[0] -eq '4B1L17Y'
                    }
                    $result | Should -BeOfType [PSCustomObject]
                    $result.Success | Should -BeTrue
                    $result.Sentinel | Should -BeExactly '1N73LL1G3NC3'
                }
            }

            Context "handles 304 (Not Modified) response status code" {

                It "of GET request" {
                    $result = Invoke-ApiRequest -Url 'resource/not-modified?json'
                    Assert-MockCalled 'Send-ApiRequest' -Scope It -Times 1 -Exactly -ParameterFilter {
                        $Request.Method -eq [System.Net.Http.HttpMethod]::Get -and
                        $Request.RequestUri -eq [uri]'resource/not-modified?json'
                    }
                    $result | Should -BeOfType [PSCustomObject]
                    $result.Success | Should -BeTrue
                }

                It "of POST request" {
                    $requestBody = [pscustomobject]@{ str = 'value' }
                    $result = Invoke-ApiRequest -Url 'resource/not-modified?json' -Body $requestBody
                    Assert-MockCalled 'Send-ApiRequest' -Scope It -Times 1 -Exactly -ParameterFilter {
                        $Request.Method -eq [System.Net.Http.HttpMethod]::Post -and
                        $Request.RequestUri -eq [uri]'resource/not-modified?json'
                    }
                    $result | Should -BeOfType [PSCustomObject]
                    $result.Success | Should -BeTrue
                }
            }

            Context "inject value of 'ETag' response header as EntityTag member of result" {

                It "of GET request" {
                    $result = Invoke-ApiRequest -Url 'resource/success/etag?json'
                    Assert-MockCalled 'Send-ApiRequest' -Scope It -Times 1 -Exactly -ParameterFilter {
                        $Request.Method -eq [System.Net.Http.HttpMethod]::Get -and
                        $Request.RequestUri -eq [uri]'resource/success/etag?json'
                    }
                    $result | Should -BeOfType [PSCustomObject]
                    $result.Success | Should -BeTrue
                    $result.Sentinel | Should -BeExactly '1N73LL1G3NC3'
                    $result.EntityTag | Should -BeExactly '4D4P7 70 CH4NG35'
                }

                It "of GET request (304 Not Modified)" {
                    $result = Invoke-ApiRequest -Url 'resource/not-modified/etag?json'
                    Assert-MockCalled 'Send-ApiRequest' -Scope It -Times 1 -Exactly -ParameterFilter {
                        $Request.Method -eq [System.Net.Http.HttpMethod]::Get -and
                        $Request.RequestUri -eq [uri]'resource/not-modified/etag?json'
                    }
                    $result | Should -BeOfType [PSCustomObject]
                    $result.Success | Should -BeTrue
                    $result.EntityTag | Should -BeExactly '4D4P7 70 CH4NG35'
                }

                It "of POST request" {
                    $requestBody = [pscustomobject]@{ str = 'value'; int = 42; bool = $true }
                    $result = Invoke-ApiRequest -Url 'resource/success/etag?json' -Body $requestBody
                    Assert-MockCalled 'Send-ApiRequest' -Scope It -Times 1 -Exactly -ParameterFilter {
                        $Request.Method -eq [System.Net.Http.HttpMethod]::Post -and
                        $Request.RequestUri -eq [uri]'resource/success/etag?json'
                    }
                    $result | Should -BeOfType [PSCustomObject]
                    $result.Success | Should -BeTrue
                    $result.Sentinel | Should -BeExactly '1N73LL1G3NC3'
                    $result.EntityTag | Should -BeExactly '4D4P7 70 CH4NG35'
                }

                It "of POST request (304 Not Modified)" {
                    $requestBody = [pscustomobject]@{ str = 'value'; int = 42; bool = $true }
                    $result = Invoke-ApiRequest -Url 'resource/not-modified/etag?json' -Body $requestBody
                    Assert-MockCalled 'Send-ApiRequest' -Scope It -Times 1 -Exactly -ParameterFilter {
                        $Request.Method -eq [System.Net.Http.HttpMethod]::Post -and
                        $Request.RequestUri -eq [uri]'resource/not-modified/etag?json'
                    }
                    $result | Should -BeOfType [PSCustomObject]
                    $result.Success | Should -BeTrue
                    $result.EntityTag | Should -BeExactly '4D4P7 70 CH4NG35'
                }
            }
        }

        Context "Test-ApiResponse" {

            It "Throws if response has `"Error`" member and doesn't have `"Success`" member" {
                {
                    Test-ApiResponse [pscustomobject]@{
                        IntProp = 42
                        Error = "Error message."
                        BoolProp = $true
                    }
                } | Should -Throw "Error message."
            }

            It "Throws if response has `"Error`" member and `"Success`" member equals False" {
                {
                    Test-ApiResponse [pscustomobject]@{
                        IntProp = 42
                        Error = "Error message."
                        BoolProp = $true
                        Success = $false
                    }
                } | Should -Throw "Error message."
            }

            It "Passes response thru if `"Success`" equals False but it doesn't have an `"Error`" member" {
                $response = [pscustomobject]@{
                    IntProp = 42
                    BoolProp = $true
                    Success = $false
                }
                Test-ApiResponse -Response $response | Should -BeExactly $response
            }

            It "Passes response thru if it has an `"Error`" member but `"Success`" equals True" {
                $response = [pscustomobject]@{
                    IntProp = 42
                    Error = "Error message."
                    BoolProp = $true
                    Success = $true
                }
                Test-ApiResponse -Response $response | Should -BeExactly $response
            }
        }
    }

    Context "Crowdin API" {

        'Content of the test file.' | Set-Content 'TestDrive:/test.dat' -NoNewline

        Mock -ModuleName 'Crowdin.PowerShell.Api1' -CommandName 'Send-ApiRequest' -MockWith {
            $requestDump = [PSCustomObject]@{
                success = $true
                method = $Request.Method.Method
                url = $Request.RequestUri
                body = @{}
            }
            foreach ($formData in $Request.Content)
            {
                $requestDump.Body.Add($formData.Headers.ContentDisposition.Name.Trim('"'), $formdata.ReadAsStringAsync().GetAwaiter().GetResult())
            }

            $responseContent = New-Object System.Net.Http.StringContent -ArgumentList @(ConvertTo-Json $requestDump -Compress)
            $responseContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('application/json')
            New-Object System.Net.Http.HttpResponseMessage -ArgumentList @([System.Net.HttpStatusCode]::NonAuthoritativeInformation) -Property @{
                RequestMessage = $Request
                ReasonPhrase = "Mock"
                Content = $responseContent
            }
        }

        function ConvertTo-Hashtable
        {
            [CmdletBinding()]
            param (
                [Parameter(ValueFromPipeline)]
                [PSObject]$InputObject
            )
            process {
                $hashtable = @{}
                foreach ($member in $InputObject.PSObject.Properties)
                {
                    $hashtable.Add($member.Name, $member.Value)
                }
                $hashtable
            }
        }

        function Compare-Hashtables
        {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory)]
                [hashtable]$Left,

                [Parameter(Mandatory)]
                [hashtable]$Right
            )

            $errLeft = $Left.Clone()
            $errValue = @{}
            $errRight = $Right.Clone()

            foreach ($key in $Left.Keys)
            {
                if ($errRight.ContainsKey($key))
                {
                    if ($errLeft[$key] -ne $errRight[$key])
                    {
                        $errValue.Add($key, @($errLeft[$key], $errRight[$key]))
                    }
                    $errLeft.Remove($key)
                    $errRight.Remove($key)
                }
            }

            $errLeft
            $errValue
            $errRight
        }

        $PSScriptRoot | Join-Path -ChildPath 'Api' | Get-ChildItem -File -Filter *.json | ForEach-Object {
            $testDataFile = $_
            $cmdletName = [IO.Path]::GetFileNameWithoutExtension($testDataFile) -csplit '-',2 -join ('-' + $Global:moduleUnderTest.Prefix)

            Context "$cmdletName" {
                $apiCmdlet = $cmdletName | Get-Command -Module $Global:moduleUnderTest -ErrorAction SilentlyContinue
                It "Command exists" {
                    $apiCmdlet | Should -Not -BeNullOrEmpty
                }
                if ($apiCmdlet -eq $null)
                {
                    return
                }

                $testCases = $testDataFile | Get-Content -Raw | ConvertFrom-Json |
                    ForEach-Object { $_.PSObject.Properties } | ForEach-Object { $_.Value | Add-Member 'case' $_.Name -PassThru } |
                    ConvertTo-Hashtable
                It "Generates valid request when called with <case>" -TestCases $testCases {
                    param($arguments, $expectedRequest)

                    $namedArguments = $arguments | ConvertTo-Hashtable
                    $actualRequest = & $apiCmdlet @namedArguments
                    Assert-MockCalled -ModuleName 'Crowdin.PowerShell.Api1' -CommandName 'Send-ApiRequest' -Scope It -Times 1 -Exactly

                    $actualRequest | Should -BeOfType [PSCustomObject]
                    $actualRequest.Method | Should -BeExactly $expectedRequest.Method
                    $actualRequest.Url | Should -BeExactly $expectedRequest.Url

                    $bodies = $actualRequest.Body, $expectedRequest.Body | ConvertTo-Hashtable
                    $errActual, $errValue, $errExpected = Compare-Hashtables @bodies
                    $errActual.Keys | Should -BeNullOrEmpty
                    $errValue.Values | Should -BeNullOrEmpty
                    $errExpected.Keys | Should -BeNullOrEmpty
                }
            }
        }
    }
}