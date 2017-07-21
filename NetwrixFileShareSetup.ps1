### NetwrixScript for enabling File Servers to work with Netrix Auditor. Windows Server 2012 and above.
### User variable is which user/group of users you want to monitor for changes, not who has read access!
### Script seeks for hidden and visible SMB Shares and adds the requested permissions, unless it is an Administrative share - also starts RemoteRegistry and sets to Automatic start
### Use the -verbose switch on the ps1 script in order to show verbose errors
### Accompanying GPO also required for Windows Firewall, Services and Audit Policy settings

$folders = Get-WmiObject -Class Win32_Share | Where-Object {($_.name -notlike 'C$' -and $_.name -notlike 'ADMIN$') -and $_.name -notlike 'IPC$'}

### You can specify the domain, otherwise the current group/accounts's domain is used. e.g. domain\username
$user = "Everyone"
Write-verbose "$user is selected as group to monitor"

### If/Elseif/Else chain will allow the user to choose the mode used for auditing.
### Refer to Configure Object-Level Access Auditing documentation for further information.
$input = Read-Host "Please enter one of the following Audit Modes:`nSuccessfulReads`nSuccessfulChanges`nFailedReads`nFailedChangeAttempts`nFailedAll`nAll`n"
if ($input -eq 'SuccessfulReads'){
    $AuditMode = 'ReadData'
    $AuditType = 'Success'
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

### Receives input from previous chain, applies appropriate audit rules
foreach($folder in $folders)
{
    try
    {
        if ($folder.Path -ne $null) {
            if ($input -ne 'All') {
                    $ACL =  Get-Acl -Audit -Path $folder.Path -ErrorAction Stop
                    $AuditRules = New-Object System.Security.AccessControl.FileSystemAuditRule($user,$AuditMode,"ObjectInherit","InheritOnly",$AuditType)
                    $ACL.AddAuditRule($AuditRules)
                    $ACL | Set-Acl -path $Folder.Path -ErrorAction Stop
                    Write-Verbose "Setting Audit Rules on $folder"
            }
            Else{
                    $ACL =  Get-Acl -Audit -Path $folder.Path -ErrorAction Stop
                    $AuditRules = New-Object System.Security.AccessControl.FileSystemAuditRule($user,$AuditMode,"ObjectInherit","InheritOnly",'Success')
                    $ACL.AddAuditRule($AuditRules)
                    $ACL | Set-Acl -path $Folder.Path -ErrorAction Stop
                    $AuditRules = New-Object System.Security.AccessControl.FileSystemAuditRule($user,$AuditMode,"ObjectInherit","InheritOnly",'Fail')
                    $ACL.AddAuditRule($AuditRules)
                    $ACL | Set-Acl -path $Folder.Path -ErrorAction Stop
                    Write-Verbose "Setting Audit Rules on $folder"
            }
        }
    
    }
    catch
    {
        Write-Error -ErrorRecord $_
    }
}

Try{
### A Try/Catch block to enable remote registry automatic startup and start the service
Write-Verbose 'Verifying if Remote Registry service is available'
Get-Service -Name 'RemoteRegistry' -ErrorAction Stop
Write-Verbose 'Updating the startup type of the Remote Registry service'
Set-Service -Name 'RemoteRegistry' -StartupType automatic -ErrorAction Stop
Write-Host "`nStarting Remote Registry`n" 
Start-Service -Name 'RemoteRegistry' -ErrorAction Stop
Write-Verbose 'No errors in RemoteRegistry processing, service successfully altered'
Get-Service -Name 'RemoteRegistry' -ErrorAction Stop
}
Catch{
Write-Warning "Error with Remote Registry:`n$_`n"
}

Write-Verbose 'Script completed'
