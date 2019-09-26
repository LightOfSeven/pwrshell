<#
.SYNOPSIS 
– Compare $null to things, not things to $null, otherwise Powershell makes mistakes
#>

if (@() -eq $null) { 'true' } else { 'false' }  # Returns false
if ($null -ne @()) { 'true' } else { 'false' }  # Returns true
