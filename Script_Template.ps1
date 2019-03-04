# Start Scripts with: 
<#
.SYNOPSIS 
– a brief explanation of what the script or function does.
.DESCRIPTION 
– a more detailed explanation of what the script or function does.
.PARAMETER name 
– an explanation of a specific parameter
. Replace name with the parameter name. You can have one of these sections for each parameter the script or function uses.
.EXAMPLE 
– an example of how to use the script or function. 
You can have multiple .EXAMPLE sections if you want to provide more than one example.
.NOTES 
– any miscellaneous notes on using the script or function.
.LINK 
– a cross-reference to another help topic; you can have more than one of these. 
If you include a URL beginning with http:// or https://, the shell will open that URL when the Help command’s –online parameter is used.
#>
$CustomErrorCode = 0

#Define functions like (Verb-Noun format):
function Start-Thing {
    [CmdletBinding()]
    param (
    )
    
    begin {
    }
    
    process {
    }
    
    end {
    }
}

# Publish exit codes determining success like: 
exit $CustomErrorCode
