### NetwrixScript for enabling File Servers to work with Netrix Auditor. Windows Server 2012 and above.
### User account must be created first in AD 
### Script seeks for all hidden and visible SMB Shares and adds the requested permissions - also starts RemoteRegistry and sets to Automatic start
### Use the -verbose switch on the ps1 script in order to show verbose errors
### Accompanying GPO also required for Windows Firewall, Services and Audit Policy settings

$folders = Get-WmiObject -Query "SELECT Path FROM Win32_Share"

### You can specify the domain, otherwise the current account's domain is used. e.g. domain\username
$user = "NetwrixAuditor"
Write-verbose "$user is selected as the user account for Audit Permissions"

### If/Elseif/Else chain will allow the user to choose the mode used for auditing.
### Refer to Configure Object-Level Access Auditing documentation for further information.
$input = Read-Host "Please enter one of the following Audit Modes:`nSuccessfulReads`nSuccessfulChanges`nFailedReads`nFailedChangeAttempts`nFailedAll`nAll`n"
if ($input -eq 'SuccessfulReads'){
    $AuditMode = 'ReadData'
    $AuditType = 'All'
}
ElseIf($input -eq 'SuccessfulChanges'){
    $AuditMode = 'DeleteSubdirectoriesAndFiles', 'Write', 'Delete', 'ChangePermissions', 'TakeOwnership'
    $AuditType = 'Success'
}
ElseIf($input -eq 'FailedReads'){
    $AuditMode = 'ReadData'
    $AuditType = 'Fail'
}
ElseIf($input -eq 'FailedChangeAttempts'){
    $AuditMode = 'DeleteSubdirectoriesAndFiles', 'Write', 'Delete', 'ChangePermissions', 'TakeOwnership'
    $AuditType = 'Fail'
}
ElseIf($input -eq 'FailedAll'){
    $AuditMode = 'DeleteSubdirectoriesAndFiles', 'Write', 'Delete', 'ChangePermissions', 'TakeOwnership', 'ReadData'
    $AuditType = 'Fail'
}
ElseIf($input -eq 'All'){
    $AuditMode = 'DeleteSubdirectoriesAndFiles', 'Write', 'Delete', 'ChangePermissions', 'TakeOwnership', 'ReadData'
    $AuditType = 'All'
    Write-host 'This configuration will place a heavier load on the Netwrix Server and DB than may be intended. Continue?' -ForegroundColor Red
    $continue = Read-Host 'Select: [Y]/[N]'
    if ($continue -ne 'Y'){
        Write-Host 'Exiting script...'
        Exit-PSSession
    }
}
Else{
    Write-Host 'Input not recognised. Script will exit, please enter the exact Audit Mode (no spaces) to proceed on next run. Case-insensitive!'
    Exit-PSSession
}

### Receives input from previous chain, applies appropriate aduit rules
foreach($folder in $folders)
{
    try
    {
        $ACL = $folder | Get-Acl -Audit -ErrorAction Stop

        $AuditRules = New-Object System.Security.AccessControl.FileSystemAuditRule($user,$AuditMode,"None","None",$AuditType)
        $ACL.SetAuditRule($AuditRules)
        $ACL | Set-Acl $Folder -ErrorAction Stop
        Write-Verbose "Setting Audit Rules on $folder"
    }
    catch
    {
        Write-Error -ErrorRecord $_
    }
}

Try{
### A Try/Catch block to enable remote registry automatic startup and start the service
Write-Verbose 'Verifying if Remote Registry service is available'
Get-Service -Name 'RemoteRegsitry' -ErrorAction Stop
Write-Verbose 'Updating the startup type of the Remote Registry service'
Set-Service -Name 'RemoteRegistry' -StartupType automatic -ErrorAction Stop
Write-Verbose 'Starting Remote Registry' 
Start-Service -Name 'RemoteRegistry' -ErrorAction Stop
Write-Verbose 'No errors in RemoteRegistry processing, service successfully altered'
}
Catch{
Write-Warning "Error with Remote Registry:`n$_`n"
}

Write-Verbose 'Script completed'
