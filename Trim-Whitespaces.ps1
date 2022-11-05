[CmdletBinding()]
param (
    [Parameter(Mandatory=$true,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [String]
    $Value
)

$Value = $Value.Trim()
$Value = $Value -replace '\s+',' '
$Value = $Value -replace '\r',' '
$Value = $Value -replace '\n',' '
$Value
        