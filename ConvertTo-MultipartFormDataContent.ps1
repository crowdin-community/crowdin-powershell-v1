function ConvertTo-MultipartFormDataContent {
    [OutputType([System.Net.Http.MultipartFormDataContent])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $Object
    )

    process {
        $content = New-Object System.Net.Http.MultipartFormDataContent
        foreach ($member in ($Object | Get-Member -MemberType Properties))
        {
            $partName = $member.Name
            $partValue = $Object.($member.Name)
            if ($partValue -is [System.IO.FileInfo])
            {
                $contentPart = New-Object System.Net.Http.StreamContent -ArgumentList ($partValue.OpenRead())
                $content.Add($contentPart, $partName, $partValue.Name)
            }
            else
            {
                $contentPart = New-Object System.Net.Http.StringContent -ArgumentList $partValue
                $content.Add($contentPart, $partName)
            }
        }
        $PSCmdlet.WriteObject($content, $false)
    }
}