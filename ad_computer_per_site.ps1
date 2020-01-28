<#
Problem Brief: With many separated OUs per site below a master OU, we
need to get a list of computer objects in Active Directory that contains
the computer name and the site it belongs to in plain text, without the
long DN per computer

Solution: Below
#>
# Set this to your top level OU(s)
$OUs = "OU=Test,DC=Your,DC=Domain,DC=com"

# Do not change
$Result = New-Object System.Collections.ArrayList
$Object = New-Object System.Collections.ArrayList

# Configure to filter days that computers have not logged onto the domain since
$DaysInactive = 90
$Time = (Get-Date).Adddays( - ($DaysInactive))

# Gathers Computer Objects
ForEach ($OU in $OUs) {
    # Parameters for Get-ADComputer
    $GACParameters = @{
        SearchBase     = $OU
        Filter         = { LastLogonDate -lt $Time -and Operatingsystem -notlike '*Server*' }
        ResultPageSize = 20000
        resultSetSize  = $null
        Properties     = "Name", "OperatingSystem", "LastLogonDate", "DistinguishedName"
    }
    ForEach($Computer in (Get-ADComputer @GACParameters)){
        $ToAdd = $Computer
        $Result.Add($ToAdd) > $null
    }
}

# Assigns sites to computer objects and outputs into $Object
ForEach($Computer in $Result){
    $Comparison = $Computer.DistinguishedName
    # Add your site names to use as a simple text filter in this case statement
    switch -wildcard ($Comparison){
        "*London*" {$Comparison = "London"}
        "*Cape Town*" {$Comparison = "Cape Town"}
        Default {$Comparison = "No site found"}
    }
    $Object.Add([PSCustomObject]@{
        Name = $Computer.Name
        Site = $Comparison
    }) > $null
}

# Returns $Object to the output stream
$Object
