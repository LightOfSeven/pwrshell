# Outside foreach loop
$i=0 
$Total = $VarForLoop.count 
$Title = "Title for Progress Bar"
 
foreach ($Var in $VarForLoop) { 
    $i++
    $Status = "{0:N0}" -f ($i / $Total * 100)
    Write-Progress -Activity "Title" -Status "Processing $i of $Total : $Status% Completed" -PercentComplete ($i / $Total * 100)

    ## Remaining code

}
