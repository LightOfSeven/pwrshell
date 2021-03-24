<#
.SYNOPSIS 
– Compare $null to things, not things to $null, otherwise Powershell makes mistakes
#>


####
# $null is on the right here, and therefore shows incorrect / inconsistent results
####

# Returns $true
$demo = $null
$demo -eq $null
 
# Returns $null
$demo = 1,2,3
$demo -eq $null

# Returns $null
$demo = 1,2,$null,3,4
$demo -eq $null
 
# Returns array of 2x $null
$demo = 1,2,$null,3,4,$null,5
$demo -eq $null

# Returns number of $null entries in the array
($demo -eq $null).Count


####
# $null is on the left here, and therefore shows correct & consistent results
####

# Returns $true
$demo = $null
$null -eq $demo
 
# Returns $false
$demo = 1,2,3
$null -eq $demo

# Returns $false
$demo = 1,2,$null,3,4
$null -eq $demo
 
# Returns $false
$demo = 1,2,$null,3,4,$null,5
$null -eq $demo

# Returns number of $null entries in the array
($demo -eq $null).Count
