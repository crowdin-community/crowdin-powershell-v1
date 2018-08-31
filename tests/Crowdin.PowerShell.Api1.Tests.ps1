$src = $MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent | Join-Path -ChildPath 'src'

Describe "Test API requests" {

    BeforeAll {
        Import-Module "$src\Crowdin.PowerShell.Api1.psd1"
    }

    AfterAll {
        Remove-Module 'Crowdin.PowerShell.Api1'
    }

    InModuleScope 'Crowdin.PowerShell.Api1' {

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
}