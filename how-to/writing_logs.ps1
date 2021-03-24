<#
.SYNOPSIS 
– Write-Log generates a log file whenever the function is called.
.DESCRIPTION 
– Writing a log with this function enables you to use severities, define a log message, 
write to a specific location and to clear the logs using the function.
.PARAMETER Severity 
– A numeric value from 1 to 4 on how severe the logged error is - 1 being a priority and 3 being a default log
1 - Critical / Halting
2 - Error / Warning
3 - Log / Informational (Default)
4 - Debug
.PARAMETER Message
- Allows a string to be set in the log with the severity and timestamp, including variables if desired. 
.PARAMETER LogPath
- Allows a custom path to be used for the log file. Default is "C:\Scripts\Logs\"
.PARAMETER ClearLog
- Boolean that if set, will delete the LogFile entirely
.EXAMPLE
– Write-Log -Message "Critical error due to $variable not being an intended value. Please check the script for invalid input" -Severity 1
.NOTES 
– The script will cause a pause for 2 seconds on every failed attempt to write a log file, 
in order to notify the terminal session of the error.
A lot of other people have log writing functions of variable complexity. 
Use any your company already uses over this one, this is an example.
#>
Function Write-Log {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
        [string]$Message,

        [Parameter(Mandatory=$False)]
        [ValidateSet('1','2','3','4')]
        [string]$Severity = '3',

        [Parameter(Mandatory=$False)]
        [string]$LogFile,
    
        [Parameter(Mandatory=$False)]
        [bool]$ClearLog = $False
    )
    Write-Verbose $Message
    $LogPath = "C:\ScriptLogs\"
    $LogFile = ($LogPath + "LogFile.txt")
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Severity $Message"
    if($ClearLog){
        Remove-Item $LogFile
    }
    if((Test-Path $LogFile) -and (Test-Path $LogPath)) {
        Add-Content -Path $LogFile -Value $Line
    }
    else {
        Write-Host "File path or file was missing, forcing creation of directory and file specified"
        New-Item -ItemType Directory -Path $LogPath -Force
        New-Item -ItemType File -Path $LogFile -Force
        Add-Content -Path $LogFile -Value $Line
        Write-Log -Message "No log found, created new log"
    }
}

Write-Log -Message @"

***** Start of check. *****
Severity meaning:
1: Critical
2: Warning
3: Informational
4: Debug
"@

