<#
.SYNOPSIS
Removes Teams including the Machine Installer that reinstalls each user login.
#>

$UsersRoot = [System.IO.Path]::Combine(($env:Public).trimend("\Public")) 
$AllUsersPath = Get-ChildItem $UsersRoot
# Stop the process if it's running
Stop-Process -Name "Teams.exe" -Force -ErrorAction SilentlyContinue

# Run the removal from AppData on all users
ForEach($User in $AllUsersPath){
    $TeamsPath = [System.IO.Path]::Combine($User, 'AppData', 'Local', 'Microsoft', 'Teams')
    $TeamsUpdateExePath = [System.IO.Path]::Combine($User, 'AppData', 'Local', 'Microsoft', 'Teams', 'Update.exe')
    try{
        if (Test-Path -Path $TeamsUpdateExePath) {
            Write-Output "Uninstalling Teams process"
            # Uninstall app
            $proc = Start-Process -FilePath $TeamsUpdateExePath -ArgumentList "-uninstall -s" -PassThru
            $proc.WaitForExit()
            Write-Output "Teams process uninstalled for $user"
        }
        else {
            Write-Output "Teams update exe in AppData is not present for $User"
        }
        if (Test-Path -Path $TeamsPath) {
            Write-Output "Deleting Teams directory"
            Remove-Item -Path $TeamsPath -Recurse -Force
            Write-Ouput "Teams directory deleted for $user"
        }
        else {
            Write-Output "No teams install was found for $User at path $TeamsPath"
        }
    }
    catch{
        Write-Error -ErrorRecord $_
    }
}
try{
    if (Test-Path -Path $TeamsMachineInstallerPath) {
        Write-Output "Deleting Teams Machine Installer"
        Remove-Item -Path $TeamsMachineInstallerPath -Recurse -Force
        Write-Output "Successful, Teams Machine Installer deleted on $Env:COMPUTERNAME"
    }
    else {
        "Not Teams Machine Installer found on $Env:COMPUTERNAME"
    }
}
catch{
    Write-Error -ErrorRecord $_
    exit /b 1
}
