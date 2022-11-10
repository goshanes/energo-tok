<#
.SYNOPSIS
    Queries web service and further processes its raw response
    by extracting useful data.
.DESCRIPTION
    Calls the web service and then the response is trimmed from
    excess whitespaces, date and time are parsed from text
    description of scheduled interruptions and stored in new
    additional fields.
.NOTES
    Depends on script Get-Interruptions being present in same directory.
.EXAMPLE
    Get-Interruptions -Region "шумен" -Location "винпром"
    Queries the web service and looks for scheduled interruptions in
    region "Шумен" while also expecting the description to contain
    the pattern "Винпром" in its content.
#>
[CmdletBinding()]
param (
    # Identifier or name of region
    [String]
    $Region,
    # Name of location or other text to look for
    # in text field 'location_text'
    [String]
    $Location
)

$culture = New-Object 'System.Globalization.CultureInfo' 'bg-BG'

$locations = & "$PSScriptRoot/Get-Interruptions.ps1" -Region $Region -Location $Location
foreach ($loc in $locations)
{
    $loc.location_period = & "$PSScriptRoot/Trim-Whitespaces.ps1" $loc.location_period
    $loc.location_text   = & "$PSScriptRoot/Trim-Whitespaces.ps1" $loc.location_text
    $loc | Add-Member -MemberType NoteProperty -Name 'location_dates' -Value ($loc.location_period)
    $loc | Add-Member -MemberType NoteProperty -Name 'location_times' -Value ($loc.location_period)
    $loc.location_dates = $loc.location_period                       `
        | Select-String -Pattern '\d{1,2}.\d{1,2}.\d{4}' -AllMatches `
        | ForEach-Object { $_.Matches }                              `
        | Select-Object -ExpandProperty Value                        `
        | ForEach-Object { [DateTime]::Parse($_, $culture) }         
    $loc.location_times = $loc.location_period                       `
        | Select-String -Pattern '\d{1,2}:\d{2}' -AllMatches         `
        | ForEach-Object { $_.Matches }                              `
        | Select-Object -ExpandProperty Value                        `
        | ForEach-Object { [TimeSpan]::Parse($_, $culture) }         
}
$locations
