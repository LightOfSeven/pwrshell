# Script to move values of one field to another
try
{
    Import-Module ActiveDirectory -ErrorAction Stop
}
catch
{
    Write-Output "Unable to import Active Directory Module, script is not able to continue"
}

    Clear-Host
    Write-Host ("This script copies an AD attribute from one field to another, for all users that have data in the source field. Please ensure the parameters are entered correctly as they are not error checked.")
    $originalfield = Read-Host("What field would you like to read from?")
    $changefield = Read-Host("What field would you like to copy the data to?")
    $users = Get-ADUser -LDAPFilter "($originalfield=*)" -Properties $originalfield, $changefield

    write-host ("The below list of users are about to be altered:")
    foreach ($user in $users) {
        write-host ($user.samaccountname)
    }
    $confirm = read-host ("Are you sure? y/N")

# Changes the value of each users $changefield in the $users variable to $originalfield
if ($confirm -eq "y") {
    Write-Host ("Confirmation granted, running script!")
    foreach ($user in $users) {
        Select-Object * -First 5 
        ForEach-Object {Set-ADObject -Identity $user.DistinguishedName -Replace @{$changefield=$($user.$originalfield)}}
        # Optional output for per-user completion
        # Write-Output ("$user.DistinguishedName processed")}
    }
    Write-Host ("Script completed for user selection.")
                                }
else {
        Write-Host ("Detected non-confirmation input, exiting...")
    }