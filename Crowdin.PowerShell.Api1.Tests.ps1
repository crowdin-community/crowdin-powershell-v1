Describe "Test API requests" {

    BeforeAll {
        Import-Module .\Crowdin.PowerShell.Api1.psd1
    }

    AfterAll {
        Remove-Module Crowdin.PowerShell.Api1
    }

    InModuleScope Crowdin.PowerShell.Api1 {

        Mock Invoke-GetRequest {
            New-Object System.Net.Http.HttpResponseMessage -Property @{
                Content = New-Object System.Net.Http.StringContent -ArgumentList '"Successful GET."'
            }
        }

        Mock Invoke-PostRequest {
            New-Object System.Net.Http.HttpResponseMessage -Property @{
                Content = New-Object System.Net.Http.StringContent -ArgumentList '"Successful POST."'
            }
        }

        It 'Send GET Request' {
            $result = Invoke-ApiRequest -Url 'some-get-url?json'
            Assert-MockCalled 'Invoke-GetRequest' -Scope It -Times 1 -Exactly -ParameterFilter {
                $Url -eq ([uri]'some-get-url?json')
            }
            $result | Should -BeOfType [string]
            $result | Should -BeExactly 'Successful GET.'
        }

        It 'Send POST Request' {
            $requestBody = [pscustomobject]@{
                key = '0123456789'
            }
            $result = Invoke-ApiRequest -Url 'some-post-url?json' -Body $requestBody
            Assert-MockCalled Invoke-PostRequest -Scope It -Times 1 -Exactly -ParameterFilter {
                $Url -eq ([uri]'some-post-url?json')
            }
            $result | Should -BeOfType [string]
            $result | Should -BeExactly 'Successful POST.'
        }
    }
}