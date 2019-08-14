<#
.SYNOPSIS
Removes Teams including the Machine Installer that reinstalls each user login.
#>

$UsersRoot = [System.IO.Path]::Combine(($env:Public).trimend("\Public")) 
$AllUsersPath = Get-ChildItem $UsersRoot
$Users = $AllUsersPath.FullName
# Stop the process if it's running
# Stop-Process -Name "Teams.exe" -Force -ErrorAction SilentlyContinue

# Run the removal from AppData on all users
ForEach($User in $Users){
    $TeamsPath = Convert-Path "$user\AppData\Local\Microsoft\Teams" -ErrorAction SilentlyContinue
    $TeamsUpdateExePath = "$TeamsPath\Update.exe"
    try{
        if (Test-Path -Path $TeamsUpdateExePath) {
            Write-Output "Uninstalling Teams process"
            # Uninstall app
            $proc = Start-Process -FilePath $TeamsUpdateExePath -ArgumentList "-uninstall -s" -PassThru
            $proc.WaitForExit()
            Write-Output "Success! Teams process uninstalled for $user.Name"
        }
        else {
            Write-Output "Not Found. Teams update exe in AppData is not present for $User"
        }
        if (Test-Path -Path $TeamsPath) {
            Write-Output "Deleting Teams directory"
            Remove-Item -Path $TeamsPath -Recurse -Force
            Write-Ouput "Success! Teams directory deleted for $user"
        }
        else {
            Write-Output "Not Found. Teams install was not found for $User at path $TeamsPath"
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
        Write-Output "Success! Teams Machine Installer deleted on $Env:COMPUTERNAME"
    }
    else {
        "Not Found. Not Teams Machine Installer found on $Env:COMPUTERNAME"
    }
}
catch{
    Write-Error -ErrorRecord $_
    exit /b 1
}
