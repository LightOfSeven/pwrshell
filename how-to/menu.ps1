# A function to show a menu
# Originally for an AWS selection of subnet / region during a lab

function Show-Menu {
    param (
        [string]$Title,
        [Parameter(Mandatory=$True)]
        [array]$Choices
    )
    
    Clear-Host
    Write-Host "================ $Title ================"
    
    $i = 0
    $total = ($choices | Measure-Object).count

    if($total -eq 1){return $Choices}

    foreach($Choice in $Choices){
        $i = $i+1
        Write-Host "$i : $Choice"
       }
    Write-Host "Q: Press 'Q' to quit."

    do{
        do{
          $selection = $null
          $selection = Read-Host "Select object [Q to quit instead]"
          if($selection -eq 'Q'){return $null}
        }
        while($selection -notmatch '^\d+$') #validate numeric only entry
    }
    while([int]$selection -lt 1 -or [int]$selection -gt $total) #validate numeric entry is in range

    $Choices[$selection]
}
