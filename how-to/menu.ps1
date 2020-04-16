# A function to show a menu
# Originally for an AWS selection of subnet / region during a lab
# TODO: Remove "Press Enter to continue...:" prompt unexpectedly appearing

function Show-Menu {
    param (
        [string]$Title,
        [array]$Choices
    )
    
    Clear-Host
    Write-Host "================ $Title ================"
    
    $i = 0
    foreach($Choice in $Choices){
        $i = $i+1
        Write-Host "$i : $Choice"
       }
    Write-Host "Q: Press 'Q' to quit."

    do{
        $selection = Read-Host "Please make a selection"
        switch ($selection)
        {
        '1' {
        'You chose option #1'
        } '2' {
        'You chose option #2'
        } '3' {
          'You chose option #3'
        }
        }
        pause
     }
     until ($selection -ne $null)

}
