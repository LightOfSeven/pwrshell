<#
.SYNOPSIS 
- This script explains and provides code for sending emails from Powershell scripts.
.DESCRIPTION 
- Since this is using native commands there is little need for a function, 
also the definition of variables is best to keep towards the beginning of the script.
#>

# Put this at the start of your script for visibility and to allow the use of $html.add()
$PSEmailServer = 'Mail destination server goes here'
$EmailDestination = "Destination email address goes here"
$FromEmail = "Mail source address goes here"
$Subject = "Email Subject Goes Here"
# Do not change these variables except for debugging
$Html = New-Object System.Collections.Generic.List[System.Object]
$Html.Add("Note to put below the title")
$Head = @"
<Title>$Subject</Title>
<style>
body { background-color:#FFFFFF;
font-family:Tahoma;
font-size:12pt; }
</style>
<br>
<H1>$Subject</H1>
"@

# <Rest of code goes here>
# Each time you want to add a line to your HTML email, use the following throughout the script
$Html.Add("")



# When you are ready to send the email, use the following
$Html = $Html | Out-String
# The PostContent switch is used to include details of which computer ran the task and when. You do not need to change this section
[string]$Body = ConvertTo-Html -Head $Head -Body $Html -PostContent @"
<h6>Report generated $Date</h6>
<h6>Generated by $env:COMPUTERNAME - script run by scheduled task</h6>
"@

# You can test something is set in order to attempt to send the email if you wish. I've left in the Write-Log function commented out in case you'd like to log the error.
if($true){
    try{
        Send-MailMessage -To "$EmailDestination" -From $FromEmail -Subject $Subject -Body $Body -BodyAsHtml -SmtpServer $PSEmailServer
    }
    catch{
        # Write-Log -Severity 1 -Message "Email sending failed with the following: $_.Exception.message"
    }
}