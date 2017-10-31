New-Variable ApiBaseUrl -Value ([uri]'https://api.crowdin.com/api/') -Option Constant
New-Variable HttpClient -Value (New-Object System.Net.Http.HttpClient -Property @{BaseAddress=$ApiBaseUrl}) -Option Constant

$ExecutionContext.SessionState.Module.OnRemove = {
    Clear-Variable -Name HttpClient
}
