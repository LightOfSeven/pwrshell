<#
.SYNOPSIS
Removes Teams including the Machine Installer that reinstalls each user login.
#>

$UsersRoot = [System.IO.Path]::Combine(($env:Public).trimend("\Public")) 
$AllUsersAppdataPath = Get-ChildItem $UsersRoot
# Stop the process if it's running
Stop-Process -Name "Teams.exe" -Force -ErrorAction SilentlyContinue

# Run the removal from AppData on all users
ForEach($User in $AllUsersAppdataPath){
    $TeamsPath = [System.IO.Path]::Combine($User, 'AppData', 'Local', 'Microsoft', 'Teams')
    $TeamsUpdateExePath = [System.IO.Path]::Combine($User, 'AppData', 'Local', 'Microsoft', 'Teams', 'Update.exe')
    try{
        if (Test-Path -Path $TeamsUpdateExePath) {
            Write-Output "Uninstalling Teams process"
            # Uninstall app
            $proc = Start-Process -FilePath $TeamsUpdateExePath -ArgumentList "-uninstall -s" -PassThru
            $proc.WaitForExit()
        }
        if (Test-Path -Path $TeamsPath) {
            Write-Output "Deleting Teams directory"
            Remove-Item -Path $TeamsPath -Recurse -Force
        }
        Write-Output "Successful removal for $User on $env:COMPUTERNAME"
    }
    catch{
        Write-Error -ErrorRecord $_
    }
}
try{
    if (Test-Path -Path $TeamsMachineInstallerPath) {
        Write-Output "Deleting Teams Machine Installer"
        Remove-Item -Path $TeamsMachineInstallerPath -Recurse -Force
    }
    Write-Output "Successful"
}
catch{
    Write-Error -ErrorRecord $_
    exit /b 1
}
