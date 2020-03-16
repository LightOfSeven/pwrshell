# Bitlocker + TPM
<#
.SYNOPSIS
 Enables Bitlocker on a, or a group of, remote computers
.DESCRIPTION
 Designed with automation and scaling in mind, this contains custom error codes for each potential failure point and attempts to enable Bitlocker
.NOTES
 The try{}catch{} blocks are to ensure the correct error code is captured during runtime
https://etflconsultancy.wordpress.com/2017/11/10/operating-system-deployment-osd-task-sequence-error-codes/
Decimal # |Hex #	| Official meaning	| Script's meaning
0	| 0x00000000	| The operation completed successfully	| Bitlocker enabled and backed up to AD successfully
11	| 0x0000000B	| An attempt was made to load a program with an incorrect format	| Windows version, Bitlocker Drive Readiness or TPM are incompatible
26	| 0x0000001A	| The specified disk or diskette cannot be accessed	| Error adding protectors to the disk
58	| 0x0000003A	| The specified server cannot perform the requested operation	| Key failed to backup to AD
82	| 0x00000052	| The directory or file cannot be created |	Error when enabling Bitlocker
119 | 0x00000077    | The system does not support the command requested. | No TPM chip present
3011| 0x00000BC3    | The requested operation is successful. Changes will not be effective until the service is restarted. | Manual visit required; TPM needed a restart so likely the script will need to be rerun in order to apply Bitlocker
#>

Start-Transcript -Path "C:\scripts\bitlocker-ps-transcript.txt" -IncludeInvocationHeader -Force

$CustomErrorCode = 0
$Hostname = $env:ComputerName
$TPM = Get-Tpm
$BitlockerStatus = Get-BitLockerVolume | Where-Object {$_.VolumeType -like "OperatingSystem"}

Write-Output "Starting process"
if($BitlockerStatus[0].ProtectionStatus -notlike "On"){
    if($BitlockerStatus[0].VolumeStatus -notlike "FullyEncrypted"){
        Write-Output "Bitlocker is not enabled, running checks for TPM"
        if($TPM.TpmPresent -ne $true){
            Write-Error -Message "TPM chip is not physically present. TPM is required by our GPO, minimum v1.2"
            $CustomErrorCode = 119
            Exit $CustomErrorCode
        }
        if($TPM.TPMReady -ne $true){
            try{
                # Attempts to wipe owner information and start the TPM chip blank, ready for encryption
                # If successful, the PC should be ready to proceed with Bitlocker encryption
                Clear-Tpm
            }
            catch{
                # We want to void errors from clear attempts as this can succeed or fail without impairing the script's function
                # The terminating error we'd like to avoid is "An owner authorisation value is required to be supplied"
                # This error does not matter if present as it just means Windows is the current owner from OEM
            }
            try{
                $restartCheck = Initialize-Tpm
            }
            catch{
                Write-Error -Message "Failed to initilize the TPM chip, whilst it's present and not in a ready state. Recommend manual eyes on the machine to find out if the TPM was locked previously."
                $CustomErrorCode = 11
                Exit $CustomErrorCode
            }
            if ($restartCheck.RestartRequired) {
                $loggedOnUser = Get-WmiObject -Class Win32_ComputerSystem | Select-Object username
                    if ($loggedOnUser.username) {
                        # A user is currently logged on
                        Write-Error -Message "TPM chip requires reboot but a user is logged in. Setting error code to recommend manual intervention"
                        $CustomErrorCode = 3011
                        Exit $CustomErrorCode
                    }
                    else {
                        Restart-Computer
                    }
            }
        }
        Write-Output "TPM in a good state, proceeding with encryption attempt"
        # Reset the variable to the updated status
        $TPM = Get-Tpm

        Write-Output "Confirming if the Windows version is correct (client versions, not server)"
        $WindowsVer = Get-WmiObject -Query 'select * from Win32_OperatingSystem where (Version like "6.2%" or Version like "6.3%" or Version like "10.0%") and ProductType = "1"'
        $SystemDriveBitLockerRDY = Get-BitLockerVolume -MountPoint $env:SystemDrive

        Write-Output "Variables set, proceeding to check TPM availability and the System Drive readiness state, before applying Bitlocker"

        #If all of the above prequisites are met, then create the key protectors, enable BitLocker, and backup the Recovery key to AD
        if ($WindowsVer -and $TPM -and $SystemDriveBitLockerRDY) {
            if ((Get-BitLockerVolume | Select-Object ProtectionStatus) -notlike ("On")){
                Write-Output "All correct, proceeding to attempt Bitlocker-ing!"
                try{
                    Write-Output "Creating the recovery key"
                    Add-BitLockerKeyProtector -MountPoint $env:SystemDrive -RecoveryPasswordProtector

                    #This is to give sufficient time for the protectors to fully take effect.
                    Start-Sleep -Seconds 15
                }
                catch{
                    Write-Error -Message "Error encountered while adding the Bitlocker key (TPM or RecoveryPasswordProtector) to the disk - this step occurs prior to contacting AD"
                    $CustomErrorCode = 26
                    Exit $CustomErrorCode
                }

                Write-Output "Getting Recovery Key GUID"
                $RecoveryKeyGUID = (Get-BitLockerVolume -MountPoint $env:SystemDrive).keyprotector | Where-Object {$_.Keyprotectortype -eq 'RecoveryPassword'} | Select-Object -ExpandProperty KeyProtectorID
                <#
                Sometimes when this script is run multiple times without reboot, multiple keyprotectors
                can exist at once on the drive. This is corrected by looping through and removing the
                protectors until only 1 remains in the variable            
                #>
                while($RecoveryKeyGUID.Count -gt 1){
                    Remove-BitlockerKeyProtector -KeyProtectorId $RecoveryKeyGUID[1] -Mountpoint C:
                    $RecoveryKeyGUID = (Get-BitLockerVolume -MountPoint $env:SystemDrive).keyprotector | Where-Object {$_.Keyprotectortype -eq 'RecoveryPassword'} | Select-Object -ExpandProperty KeyProtectorID
                }
                try {
                    Write-Output "1st attempt: Backing up the Recovery to AD."
                    Backup-BitLockerKeyProtector -MountPoint $env:SystemDrive -KeyProtectorId $RecoveryKeyGUID
                    #Due to our Group Policy not allowing Bitlocker to be enabled if it cannot backup to AD, we only try enabling if the backup is successful
                    Write-Output "No error during backup, attempting to enable encryption"
                    Enable-BitLocker -MountPoint $env:SystemDrive -TpmProtector -UsedSpaceOnly
                    Write-Output "Bitlocker is now enabled and active. Success! Reboot required."
                }
                catch [System.IO.FileNotFoundException]{
                    Write-Output "There was an issue with the ReAgent.xml file, attempting rename and retry"
                    Rename-Item -Path "C:\Windows\System32\Recovery\ReAgent.xml" -NewName "ReAgent.xml.old" -Force
                    # retrying
                    try{
                        Write-Output "2nd attempt: Backing up the Recovery to AD."
                        Backup-BitLockerKeyProtector -MountPoint $env:SystemDrive -KeyProtectorId $RecoveryKeyGUID
                        Write-Output "No error during backup, attempting to enable encryption"
                        Enable-BitLocker -MountPoint $env:SystemDrive -TpmProtector -UsedSpaceOnly
                    }
                    catch{
                        Write-Error "Error enabling Bitlocker"
                        Write-Error "There was no access to AD during the backup attempt"
                        $CustomErrorCode = 58
                    }
                }
                catch{
                    Write-Error "Error enabling Bitlocker"
                    Write-Error "Unable to save Bitlocker key protector to AD or there was an issue with the ReAgent file that could not be resolved"
                    $CustomErrorCode = 58
                    Exit $CustomErrorCode
                }
                
                #Error code remains 0 for success - unless a non-terminating error has been generated
                #Restarting the computer, to begin the encryption process - will ONLY restart if there are no users logged on
                if($CustomErrorCode -eq 0){
                    $loggedOnUser = Get-WmiObject -Class Win32_ComputerSystem | Select-Object username
                    if ($loggedOnUser.username) {
                        # A user is currently logged on
                        Write-Output "Succesful but requires restart to encrypt"
                    }
                    else {
                        Restart-Computer
                    }
                }
            }
            else{
            Write-Debug "Bitlocker is already enabled for this computer, skipping and leaving error code as 0"
            Write-Output "Bitlocker is already enabled and active. Success!"
            }
        }
        else {
            Write-Error "Computer $Hostname failed to apply Bitlocker due to Windows Version, Bitlocker drive readiness or TPM version being incorrect/incompatible"
            $CustomErrorCode = 11
        }
    }
    else{
        try{
            Resume-Bitlocker -MountPoint C:
            Write-Output "Bitlocker was paused, so we resumed it."
            Write-Output "Bitlocker is now enabled and active. Success!"
        }
        catch [System.IO.FileNotFoundException]{
            Write-Output "Bitlocker is encrypting the disk but is not active"
            Write-Output "Resuming is being reattempted after fixing the ReAgent.xml file"
            Rename-Item -Path "C:\Windows\System32\Recovery\ReAgent.xml" -NewName "ReAgent.xml.old" -Force
            # retrying
            Resume-Bitlocker -MountPoint C:
            Write-Output "Bitlocker was paused, so we resumed it."
            Write-Output "Bitlocker is now enabled and active. Success!"
        }
        catch {
            Write-Error "Bitlocker was paused but unforeseen issues occured resuming it."
            Write-Output "Recommend manual eyes on the PC to evaluate"
        }
    }
}
else{
    Write-Output "Bitlocker is already enabled and active. Success!"
}
Exit $CustomErrorCode
