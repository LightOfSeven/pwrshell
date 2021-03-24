<#
.SYNOPSIS 
– A consistent and more fully featured way to prompt choices to the console.
.DESCRIPTION 
– Often you see people running while or until loops to capture expected input. 
There is instead a class we can use from .NET to provide a choice prompt.
Using the choice prompt code below, we get properly formatted choice prompts with optional help text. 
Far superior to repeatedly 'rolling your own' choice looping.
.PARAMETER name 
– Choice Prompt
.EXAMPLE 
– The example is in the script below
.NOTES 
– The & symbol is unique for this function, taking the first letter and using this instead of the inputted text for the choice.
Wrapping this in a function makes it highly portable, though a little more is required to bring variables into the function properly.
#>


# Parameters for choice prompt
param
(
    [string]$Caption    = 'Confirm',
    [string]$Message    = 'Are you sure you want to continue?',
    [string[]]$Choices  = ('&Yes', 'Continue', '&No', 'Stop'),
    [int]$DefaultChoice = 0
)

$ChoiceDescriptions = @()
for($i = 0; $i -lt $Choices.Count; $i += 2){
    $c = [System.Management.Automation.Host.ChoiceDescription]$Choices[$i]
    $c.HelpMessage = $Choices[$i + 1]
    $ChoiceDescriptions += $c
}

$Host.UI.PromptForChoice($Caption, $Message, [System.Management.Automation.Host.ChoiceDescription[]]$ChoiceDescriptions, $DefaultChoice)
