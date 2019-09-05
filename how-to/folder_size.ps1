<#
Windows folders don't track size, you must add up the size of all files
below the path you wish to measure, for that we measure the length attribute
#>

Get-ChildItem -Path "Insert Path Here" -File -Recurse |
Measure-Object -Property Length -Sum
