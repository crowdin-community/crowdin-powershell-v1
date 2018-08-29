$src = $MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent | Join-Path -ChildPath 'src'

Describe "Test API requests" {

    BeforeAll {
        Import-Module "$src\Crowdin.PowerShell.Api1.psd1"
    }

    AfterAll {
        Remove-Module Crowdin.PowerShell.Api1
    }

    InModuleScope Crowdin.PowerShell.Api1 {

        Mock Invoke-GetRequest {
            $request = [PSCustomObject]@{
                Method = 'GET'
                Url = $Url
                Body = $null
            }
            $responseContent = New-Object System.Net.Http.StringContent -ArgumentList (ConvertTo-Json $request)
            $responseContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('application/json')
            New-Object System.Net.Http.HttpResponseMessage -Property @{
                Content = $responseContent
            }
        }

        Mock Invoke-PostRequest {
            $request = [PSCustomObject]@{
                Method = 'POST'
                Url = $Url
                Body = $Body | ConvertTo-Json -Compress
            }
            $responseContent = New-Object System.Net.Http.StringContent -ArgumentList (ConvertTo-Json $request)
            $responseContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('application/json')
            New-Object System.Net.Http.HttpResponseMessage -Property @{
                Content = $responseContent
            }
        }

        Context "Invoke-ApiRequest" {

            It "Send GET request if called without body" {
                $result = Invoke-ApiRequest -Url 'some-get-url?json'
                Assert-MockCalled 'Invoke-GetRequest' -Scope It -Times 1 -Exactly
                $result | Should -BeOfType [PSCustomObject]
                $result.Method | Should -BeExactly 'GET'
                $result.Url | Should -BeExactly 'some-get-url?json'
                $result.Body | Should -BeExactly $null
            }

            It "Send POST request if called with body" {
                $requestBody = [pscustomobject]@{
                    str = 'value'
                    int = 42
                    bool = $true
                }
                $result = Invoke-ApiRequest -Url 'some-post-url?json' -Body $requestBody
                Assert-MockCalled 'Invoke-PostRequest' -Scope It -Times 1 -Exactly
                $result | Should -BeOfType [PSCustomObject]
                $result.Method | Should -BeExactly 'POST'
                $result.Url | Should -BeExactly 'some-post-url?json'
                $result.Body | Should -BeExactly '{"str":"value","int":42,"bool":1}'
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