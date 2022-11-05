<#
.SYNOPSIS
    Example run checking upcoming service interruptions
    in region "Варна", area "Аспарухово".
    If the report returns anything at the output
    then a web browser is launched for viewing received HTML.
#>

$html = & "$PSScriptRoot/Get-Interruptions-Html.ps1" -Region "варна" -Location "аспарухово"

if ($null -ne $html -and $html.Length -gt 0)
{
    $temp = [System.IO.Path]::GetTempFileName()
    $temp = [System.IO.Path]::GetFileNameWithoutExtension($temp) + ".html"
    try {
        # write report to file
        $html | Set-Content -Path $temp -Encoding utf8NoBOM
        # launch report in browser
        Invoke-Item $temp
    }
    finally {
        # delay a bit and delete report file
        Start-Sleep -Seconds 5
        [System.IO.File]::Delete($temp)
    }
}
