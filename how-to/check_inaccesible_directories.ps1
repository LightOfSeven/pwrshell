# Use case: NTFS file system corruption
# Checking which folder metadata is inaccessible. This is not complete as it misses corrupted files, but helps gauge scope of the issue

$DriveLetter = <Insert drive letter or directory here>
$errors=@()
get-childitem -recurse $DriveLetter -ea silentlycontinue -ErrorVariable +errors | Out-Null
$errors.Count
$errors.CategoryInfo.TargetName | Out-File -FilePath "C:\Scripts\Inaccessible_Files.txt" -Append
