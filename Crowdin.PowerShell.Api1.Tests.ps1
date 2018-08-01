Describe "Test API requests" {

    BeforeAll {
        Import-Module .\Crowdin.PowerShell.Api1.psd1
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

        It "Send GET Request" {
            $result = Invoke-ApiRequest -Url 'some-get-url?json'
            Assert-MockCalled 'Invoke-GetRequest' -Scope It -Times 1 -Exactly
            $result | Should -BeOfType [PSCustomObject]
            $result.Method | Should -BeExactly 'GET'
            $result.Url | Should -BeExactly 'some-get-url?json'
            $result.Body | Should -BeExactly $null
        }

        It "Send POST Request" {
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
}