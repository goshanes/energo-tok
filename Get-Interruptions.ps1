<#
.SYNOPSIS
    Queries web service for planned interruptions.
.DESCRIPTION
    Queries web service for planned interruptions
    and returns deserialized response, optionally
    filtered by region and simple pattern in text.
.NOTES
    Depends on script Get-Interruptions being present in same directory.
    If parameters -Region and -Location are unset then all reported
    schedules will be returned.
.EXAMPLE
    Get-Interruptions -Region "шумен" -Location "винпром"
    Queries the web service and looks for scheduled interruptions in
    region "Шумен" while also expecting the description to contain
    the pattern "Винпром" in its content.
#>
[CmdletBinding()]
param (
    # Numerical identifier or name of region
    [String]
    $Region,
    # Name of location or other text to look for
    # in text field 'location_text'
    [String]
    $Location
)

# Magic strings below. Change on your own responsibility.
$url = "https://www.energo-pro.bg/bg/profil/xhr/?method=get_interruptions&{}"
$headers = @{
    "Accept" = "application/json, text/javascript, */*; q=0.01";
    "Referer" = "https://www.energo-pro.bg/bg/planirani-prekysvanija";
    "X-Requested-With" = "XMLHttpRequest";
}

$temp = [System.IO.Path]::GetTempFileName()

try {
    Invoke-WebRequest -Uri $url -Headers $headers -OutFile $temp

    $areas = Get-Content $temp | ConvertFrom-Json

    if ([String]::IsNullOrWhiteSpace($Region) -ne $true)
    {
        $area = $areas `
            | Where-Object { $_.area_name -eq $Region -or $_.area_id -eq $Region } `
            | Select-Object -First 1
        $areas = @($area)
    }
    foreach ($area in $areas) {
        $locations = $area.area_locations
        if ([string]::IsNullOrWhiteSpace($Location) -ne $true)
        {
            $locations = $locations | Where-Object { $_.location_text -like ('*' + $Location + '*') }
        }
        $locations | Select-Object -Property location_id, location_interruption, location_period, location_text
    }
}
finally {
    [System.IO.File]::Delete($temp)
}
