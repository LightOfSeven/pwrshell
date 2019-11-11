## TODO ##
# Add synopsis + proper help

# Only required to add sequentially as per the below example

$SourcePaths = [System.Collections.ArrayList]@()
$DestinationPaths = [System.Collections.ArrayList]@()

# Add your paths using .Add("<path here") to the two comparison objects

$SourcePaths.Add("C:\testfiles\A") > $null
$DestinationPaths.Add("C:\testfiles\B") > $null


function Compare-Directories {
    param (
        [System.Collections.ArrayList]$ReferenceDirectories,
        [System.Collections.ArrayList]$DifferenceDirectories
    )
    
    begin{
        # Check to see if the path count matches
        if($ReferenceDirectories.Count -ne $DifferenceDirectories.Count){
            throw @"
The number of directories defined in the reference object is different to the number of directories defined
in the difference object. Source: $ReferenceDirectories.Count Destination: $DifferenceDirectories.Count.`n 
These must be equal to run a comparison.
"@
            break
        }
    }
    process{
        $FileInfoReference = ForEach($Path in $ReferenceDirectories){
            foreach($item in (Get-ChildItem -Path $Path -Recurse -Force)){
                [PSObject] @{
                    Name = $item.Name
                    Hash = $item.GetHashCode()
                }
            }
        }
        $FileInfoDifference = ForEach($Path in $DifferenceDirectories){
            foreach($item in (Get-ChildItem -Path $Path -Recurse -Force)){
                [PSObject] @{
                    Name = $item.Name
                    Hash = $item.GetHashCode()
                }
            }
        }
    }
    end{
        Compare-Object -ReferenceObject $FileInfoReference -DifferenceObject $FileInfoDifference
        Compare-Object -ReferenceObject $FileInfoDifference -DifferenceObject $FileInfoReference
    }
}

Compare-Directories -ReferenceDirectories $SourcePaths -DifferenceDirectories $DestinationPaths | 
Select-Object @{Name="FileName" ; Expression={$_.InputObject.Name}}, @{Name="FileHash" ; Expression={$_.InputObject.Hash}}, SideIndicator
