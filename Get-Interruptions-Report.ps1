<#
.SYNOPSIS
    Queries web service and builds a report of upcoming interruptions.
.DESCRIPTION
    Calls the web service which returns complete set of planned
    interruptions, regardless of whether they have already passed,
    and also combines several interruption events into a single message.
    This script can break down a single record into several time windows,
    as desribed in text field 'location_period', by precisely extracting
    respective start time (field 'Since') and end time (field 'Until')
    of every interruption event.
    By default past events will not be returned, except when switch
    -IncludeOld is provided.
    Sometimes there are duplicate records classified as both 'long' and
    'short' type, which seems to be a usual oversight by the publisher.
    By default this script will return the unique items only, except when
    switch -IncludeDuplicates is provided.
.NOTES
    Depends on script Get-Interruptions-Parsed being present in same directory.
.EXAMPLE
    Get-Interruptions -Region "шумен" -Location "винпром"
    Queries the web service and looks for upcoming interruptions in
    region "Шумен" while also expecting the description to contain
    the pattern "Винпром" in its content.
.EXAMPLE
    Get-Interruptions -Region "варна" -Location "аспарухово"
    Queries the web service and looks for interruptions in
    region "Варна" while also expecting the description to contain
    the pattern "Аспарухово" in its content. All events reported
    by the web service will be returned -- both past and upcoming.
#>
[CmdletBinding()]
param (
    # Identifier or name of region
    [String]
    $Region,
    # Name of location or other text to look for
    # in text field 'location_text'
    [String]
    $Location,
    # Whether to include past events
    [switch]
    $IncludeOld = $false,
    # By default the script would try to remove duplicate entries for same location.
    # Specifying this switch will leave original dataset unfiltered
    [switch]
    $IncludeDuplicates = $false
)

$now = [DateTime]::Now

$items = & "$PSScriptRoot/Get-Interruptions-Parsed.ps1" -Region $Region -Location $Location

if ($IncludeDuplicates -ne $true)
{
    # sometimes there are duplicate 'long-short' records for same location
    $items = $items `
        | Group-Object -Property location_id `
        | ForEach-Object { $_.Group | Select-Object -First 1 }
}

$items = $items `
    | ForEach-Object {
        $out = $_
        $sinceDate = $out.location_dates | Select-Object -First 1
        $untilDate = $out.location_dates | Select-Object -Last 1
        $days = ($untilDate - $sinceDate).Days
        (0..$days) `
            | ForEach-Object {
                $date = $sinceDate.AddDays($_)
                $rem = 0
                $intervals = [Math]::DivRem($out.location_times.Count, 2, [ref]$rem).Item1
                if ($intervals -gt 0) {
                    (0..($intervals-1)) `
                    | ForEach-Object {
                        @{
                            Id     = $out.location_id;
                            Type   = $out.location_interruption;
                            Since  = $date.Add(($out.location_times | Select-Object -Skip ($_ * 2)     -First 1));
                            Until  = $date.Add(($out.location_times | Select-Object -Skip ($_ * 2 + 1) -First 1));
                            Period = $out.location_period;
                            Text   = $out.location_text;
                        }
                    }
                }
            }
    } `
    | Where-Object { $IncludeOld -eq $true -or $_.Until -gt $now } `
    | Sort-Object -Property Since, Until                           `
    | Select-Object -Property Id, Type, Since, Until, Period, Text

$items
