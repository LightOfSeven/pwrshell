$PathFrom = "\\testserver\example\path"
$PathTo = "\\anothertestserver\example\path"

$startTime = Get-Date
Copy-Item -path "$PathFrom" -Destination "$PathTo"
$endTime = Get-Date

$timeElapsed = $endTime - $startTime
$timeElapsed | Out-String | Write-Host
