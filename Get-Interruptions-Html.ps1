<#
.SYNOPSIS
    Queries web service and builds a report of upcoming interruptions
    in HTML table format.
.DESCRIPTION
    Upcoming interruptions, as reported by integrated query to web service,
    are conveniently transformed into a report presented as table via HTML markup.
    Only when there is at least one interruption event matching provided
    filtering criteria (depending on arguments -Region and -Location)
    then respective HTML code will be generated. Otherwise this script will just
    exit without any output.
.NOTES
    Depends on script Get-Interruptions-Report being present in same directory.
.EXAMPLE
    Get-Interruptions -Region "шумен" -Location "винпром"
    Queries the web service and looks for upcoming interruptions in
    region "Шумен" while also expecting the description to contain
    the pattern "Винпром" in its content.
#>
[CmdletBinding()]
param (
    # Identifier or name of region
    [String]
    $Region,
    # Name of location
    [String]
    $Location,
    # Whether to return only a table as an HTML fragment
    # instead of a complete web page
    [switch]
    $Fragment
)

$items = & "$PSScriptRoot/Get-Interruptions-Report.ps1" -Region $Region -Location $Location

if ($items.Count -gt 0)
{
    $items = $items `
        | Select-Object -Property Since, Until, Period, Text
    $html = ''
    if ($Fragment.IsPresent)
    {
        $html = $items `
            | ConvertTo-Html -As Table -Fragment
    }
    else
    {
        $html = $items `
            | ConvertTo-Html -As Table `
                -Head '<style>td,th{border:1px solid}</style>'
    }

    $html = $html -replace '&lt;','<'
    $html = $html -replace '&gt;','>'
    $html
}
