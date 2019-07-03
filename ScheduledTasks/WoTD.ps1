<#
.SYNOPSIS 
– This script pops up a simple Windows dialog box with a Word of the Day
.DESCRIPTION 
– I run this on login from Task Scheduler - an example of my earliest scripting.
#>

$choices = @(
    "Quixotic: foolishly impractical especially in the pursuit of ideals",
    "Prosaic: lacking poetic beauty",
    "Puissant: powerful",
    "Apophenia: tendency to mistakenly perceive connections and meaning between unrelated things",
    "Effluvium: an offensive exhalation or smell",
    "Moxie: energy, pep, courage, determination",
    "Sedulous: involving or accomplished with careful perseverance"
)

$choice = Get-Random -Maximum $choices.Count
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup($choices[$choice],0,"QotD")
