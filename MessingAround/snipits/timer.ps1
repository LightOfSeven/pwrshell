$TimeStart = Get-Date
$TimeEnd = $timeStart.AddSeconds(30)
$TimeNow = $TimeStart
while($TimeNow -le $TimeEnd){
    $TimeNow = Get-Date
#    Write-Output "$TimeNow is not greater than $TimeEnd"
    Write-Output "Loop restarts. Time left:" 
    $RemainingMinutes = ($TimeEnd - $TimeNow).Minutes
    $RemainingSeconds = ($TimeEnd - $TimeNow).Seconds
    Write-Output "$RemainingMinutes minutes and $RemainingSeconds seconds"
    Start-Sleep 2
}
