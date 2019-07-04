#requires -Module ActiveDirectory

<#
.SYNOPSIS 
– Gets last 100 events matching ID 4624 from DCs and returns the IP & time a given user logged on with.
.DESCRIPTION 
- Made for a specific query on /r/sysadmin Discord
.PARAMETER User 
- UPN of the user(s) you want to query. Accepts arrays or a string.
#>

function Get-LoginEvents {
    param (
        [CmdletBinding()]
        [Parameter(Mandatory=$True)]
        $Users,

        [Parameter(Mandatory=$True)]
        $Path,

        $DomainControllers = (Get-ADDomainController).Hostname
    )

    ForEach($User in $Users){
        $Events = Invoke-Command -ComputerName $DomainControllers -ScriptBlock {
            $Events = Get-EventLog -LogName Security -Newest 100 -instanceid 4624 -message "*$user*"
            $Events | Select-Object PSComputerName, Message, TimeGenerated
        }
        
        $OutputForCSV = New-Object System.Collections.Generic.List[System.Object]
        
        ForEach ($Item in $Events){
            #TODO fix True output from this command without $null'ing the $item variable.
            $Item.Message -match "(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})"
            $OutputForCSV.Add(
                [PSCustomObject]@{
                    DomainController = $Item.PSComputerName
                    SourceIP = ($matches[1])
                    User = $user
                    Time = $Item.TimeGenerated
                }
            )
        }
        
        $OutputForCSV | Export-CSV -Path $Path -NoTypeInformation
        }
}

Get-LoginEvents

<#
Local version
$user = whoever
$Events = Get-EventLog -LogName Security -Newest 100 -instanceid 4624 -message "*$user*"
$Events = $Events | Select-Object PSComputerName, Message

ForEach ($Item in $Events){
    $Item.Message -match "(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})"
    [PSCustomObject]@{
        DomainController = $Item.PSComputerName
        SourceIP = ($matches[1])
        User = $user
    }
}
#>
