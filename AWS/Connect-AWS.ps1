[CmdletBinding()]
Param(
    [switch]$SkipUpdateCheck,
    [switch]$UseDefaultRegion
)

Write-Verbose "Importing AWS Powershell Module"
Try{
    Import-Module AWSPowershell
}
Catch{
    Write-Error "$_"
    exit
}

If(-not $SkipUpdateCheck){
    # Compare local to online AWS Powershell module versions
    Write-Verbose "Retrieving AWS module versions from local and online repositories"
    $AWSVersionFull = Get-AWSPowerShellVersion
    [Version]$OnlineVersion = Find-Module AWSPowershell | Select-Object Version -ExpandProperty Version
    $AWSVersionFull -match 'Version\s(.{4,9})' > $null
    Write-Verbose "Installed AWS Powershell module version is $Matches[1]"
    Write-Verbose "Online AWS Powershell module version is $OnlineVersion.Version"

    # Take action based on the result, either prompt or continue
    if([Version]$Matches[1] -eq $OnlineVersion){
        Write-Verbose "The versions match and therefore no update action was taken"
        Write-Host "AWS Module is up to date"
    }
    else{
        Write-Verbose "The versions are mismatched, there a prompt will be generated to confirm if an update should occur"
        Add-Type -AssemblyName PresentationFramework
        $MsgBoxInput =  [System.Windows.MessageBox]::Show('Would you like to update the AWS Powershell Module?','A new update is available','YesNoCancel','Info')
        switch($MsgBoxInput){
            'Yes' {
                Write-Host "You pressed yes, administrative permissions required"
                Write-Verbose "As yes was selected, the module will update"
                Remove-Module AWSPowershell
                Start-Process -FilePath "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File 'Update-AWSModule.ps1'" -WorkingDirectory $PSScriptRoot -Verb runAs -Wait 
                Write-Verbose "The update process has run, reimporting the new version"
                Import-Module AWSPowershell
                $AWSVersionFull = Get-AWSPowerShellVersion
                $AWSVersionFull -match 'Version\s(.{4,9})' > $null
                Write-Host "Version now installed:"
                $Matches[1]
            }
            'No' {
                Write-Host "You pressed no"
                Write-Verbose "As no was selected, the module will not update and the user can proceed with other tasks using the AWS Module"
            }
            'Cancel' {
                Write-Host "You pressed cancel"
                exit
            }
        }
    }
}

# Profile selector, we ignore the default profile if there is multiple profiles on the machine. This prevents a command intended for one purpose being misused for another.
$Profiles = Get-AWSCredential -ListProfileDetail
if(-not (Get-AWSCredential -ListProfileDetail)){
    Write-Host "You must set up an AWS Credential for this user account."
    Write-Host "Setting this up for the IAM user: https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html"
    Write-Host "For setting up the AWS credential store when you have the keys, see https://docs.aws.amazon.com/powershell/latest/userguide/specifying-your-aws-credentials.html"
    exit
}
elseif($Profiles.Count -gt 1) {
    # Prints a menu to select which profile you want to use
    Write-Host "Which profile?"
    $menu = @{}
    for ($i=1;$i -le $Profiles.count; $i++){ 
        Write-Host "$i. $($Profiles[$i-1].ProfileName)" 
        $menu.Add($i,($Profiles[$i-1].name))
    }
    do {
        [int]$Answer = Read-Host 'Enter selection'
    } until ([int]$Answer)
    # This stores the selection from the menu
    $Selection = $Profiles[$Answer -1]
}
else{
    $Selection = $Profiles[0]
}
$ProfileSelection = $Selection.ProfileName
Set-AWSCredential -ProfileName $ProfileSelection -Scope Global

# Similar thing for the regions
$Region = Get-DefaultAWSRegion
if($Region){
    if(-not $UseDefaultRegion){
        # There is a default set currently
        $RegionName = $Region.$RegionName
        $Message = "Would you like to change the default region? (currently $RegionName)" 
        Add-Type -AssemblyName PresentationFramework
        $MsgBoxInput =  [System.Windows.MessageBox]::Show("Would you like to change the default region? (currently $RegionName)",'Region Selection','YesNo','Info')
        switch($MsgBoxInput){
            'Yes' {
                $RegionChoices = Get-AWSRegion
                Write-Host "Which Region?"
                $menu = @{}
                for ($i=1;$i -le $RegionChoices.count; $i++){ 
                    Write-Host "$i. $($RegionChoices[$i-1].Region)" 
                    $menu.Add($i,($RegionChoices[$i-1].name))
                }
                do {
                    [int]$Answer = Read-Host 'Enter selection'
                } until ([int]$Answer)
                # This stores the selection from the menu
                $RegionSelection = $RegionChoices[$Answer -1]
                Set-DefaultAWSRegion -Region $RegionSelection.Region -Scope Global
            }
            'No' {
                # Do nothing
            }
        }
    }
}
else{
    Write-Host "No default region detected, a region needs to be set"
    $RegionChoices = Get-AWSRegion
    Write-Host "Which Region?"
    $menu = @{}
    for ($i=1;$i -le $RegionChoices.count; $i++){ 
        Write-Host "$i. $($RegionChoices[$i-1].Region) $($RegionChoices[$i-1].Name)" 
        $menu.Add($i,($RegionChoices[$i-1].Name))
    }
    do {
        [int]$Answer = Read-Host 'Enter selection'
    } until ([int]$Answer)
    # This stores the selection from the menu
    $RegionSelection = $RegionChoices[$Answer -1]
    Set-DefaultAWSRegion -Region $RegionSelection.Region -Scope Global
}
$RegionSelectionFriendlyName = (Get-DefaultAWSRegion).Name
Write-Host "Account selected: $ProfileSelection"
Write-Host "Region selected: $RegionSelectionFriendlyName"

# Now that a region and credential are in place, running any further AWS cmdlets will function as expected. Go forth and create! 
