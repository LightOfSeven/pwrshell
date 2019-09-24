function Copy-FirefoxBookmarks{
    param(
        [Parameter(Mandatory=$true,HelpMessage="This is usually the samaccountname, it must match the local user profile name on the target machine")]
        [string]$UserProfileName,

        [Parameter(Mandatory=$true)]
        $FileDestination
    )

    $UsersRoot = [System.IO.Path]::Combine(($env:Public).trimend("\Public")) 
    $UserPath = $UsersRoot + "\" + $UserProfileName
    $FirefoxPath = "$UserPath\AppData\Roaming\Mozilla\Firefox\"
    if(Test-Path $FirefoxPath){
        Write-Output "Firefox is installed for this user"
        $ProfileSettings = Get-Content "$FirefoxPath\profiles.ini"
        $DefaultProfile = (($ProfileSettings | Select-String -Pattern 'Default=1' -Context 1).Context.PreContext)
        $ProfileName = $DefaultProfile.split("/")[1]
        $FileToCopy = Get-ChildItem -Path "$FirefoxPath\Profiles\$ProfileName" -recurse | Where-Object{$_.Name -like "places.sqlite"}
        try{
            Copy-Item -Path $FileToCopy -Destination $FileDestination
        }
        catch{
            Write-Warning "Error copying!"
            throw
        }
    }
Copy-FirefoxBookmarks
