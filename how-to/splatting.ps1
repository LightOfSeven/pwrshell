<#
.SYNOPSIS 
– Splatting is for readability only. When a one-liner is getting hard to read due to the number of switches, Splatting is a way of improving readability.
.DESCRIPTION 
– In order to use Splatting, we add the switches in a switch block and call the variable as the parameters, rather than define them in-line
This enables us to properly space and show our settings in an easy to read manner, which is far easier to read.
.PARAMETER name 
– Splatting
.EXAMPLE 
– The example is in the script below
.NOTES 
– @{} generates an array, which means if you're planning on iteratively adding items you may want an ArrayList instead. Consider this before reusing the code
#>

# Instead of
Get-Content -Path C:\MyText.txt -ReadCount 1 -TotalCount 3 -Force -Delimiter "," -Filter '*' -Include * -Exclude 'a'

# Use
$getContentParameters = @{
    'Path'       = 'C:\MyText.txt'
    'ReadCount'  = 1
    'TotalCount' = 3
    'Force'      = $true
    'Delimiter'  = ','
    'Filter'     = '*'
    'Include'    = '*'
    'Exclude'    = 'a'
 }
 Get-Content @getContentParameters
