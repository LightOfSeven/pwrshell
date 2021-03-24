<#
.SYNOPSIS 
– Sorts out the mess that is everyone's downloads folder. Top level only.
#>

# Get everything except directories
$Files = Get-ChildItem -Path "$env:userprofile\Downloads" -Attributes !Directory

ForEach($File in $Files){
    $Month = $File.LastWriteTime.Month
    $NameOfMonth = (Get-Culture).DateTimeFormat.GetMonthName($Month)
    $Year = $File.LastWriteTime.Year
    $FolderPath = "$env:Userprofile\Downloads\$Year\$Month`-$NameOfMonth"

    # Backtick ` escapes the special character in the below
    if(-not (Test-Path -Path $FolderPath)){
        # Creates the Directory and ignores errors (such as read-only access to the directory)
        New-Item -Path $FolderPath -ItemType Directory -Force -ErrorAction SilentlyContinue
    }
    # Moves the item and ignores errors (such as read-only access to the directory or locked files)
    Move-Item -Path $File.FullName -Destination $FolderPath -ErrorAction SilentlyContinue
}
