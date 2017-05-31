# Theme
# Host Foreground
$Host.PrivateData.ErrorForegroundColor = 'Red'
$Host.PrivateData.WarningForegroundColor = 'Yellow'
$Host.PrivateData.DebugForegroundColor = 'Green'
$Host.PrivateData.VerboseForegroundColor = 'Blue'
$Host.PrivateData.ProgressForegroundColor = 'Gray'

# Host Background
$Host.PrivateData.ErrorBackgroundColor = 'Gray'
$Host.PrivateData.WarningBackgroundColor = 'Gray'
$Host.PrivateData.DebugBackgroundColor = 'Gray'
$Host.PrivateData.VerboseBackgroundColor = 'Gray'
$Host.PrivateData.ProgressBackgroundColor = 'Cyan'

# Further color edits
$Host.ui.rawui.BackgroundColor = 'Black'

# Check for PSReadline
if (Get-Module -ListAvailable -Name "PSReadline") {
    $options = Get-PSReadlineOption

    # Foreground
    $options.CommandForegroundColor = 'Yellow'
    $options.ContinuationPromptForegroundColor = 'DarkYellow'
    $options.DefaultTokenForegroundColor = 'DarkYellow'
    $options.EmphasisForegroundColor = 'Cyan'
    $options.ErrorForegroundColor = 'Red'
    $options.KeywordForegroundColor = 'Green'
    $options.MemberForegroundColor = 'DarkGreen'
    $options.NumberForegroundColor = 'DarkGreen'
    $options.OperatorForegroundColor = 'DarkCyan'
    $options.ParameterForegroundColor = 'DarkCyan'
    $options.StringForegroundColor = 'Blue'
    $options.TypeForegroundColor = 'Blue'
    $options.VariableForegroundColor = 'Green'

    # Background
    $options.CommandBackgroundColor = 'Black'
    $options.ContinuationPromptBackgroundColor = 'Black'
    $options.DefaultTokenBackgroundColor = 'Black'
    $options.EmphasisBackgroundColor = 'Black'
    $options.ErrorBackgroundColor = 'Black'
    $options.KeywordBackgroundColor = 'Black'
    $options.MemberBackgroundColor = 'Black'
    $options.NumberBackgroundColor = 'Black'
    $options.OperatorBackgroundColor = 'Black'
    $options.ParameterBackgroundColor = 'Black'
    $options.StringBackgroundColor = 'Black'
    $options.TypeBackgroundColor = 'Black'
    $options.VariableBackgroundColor = 'Black'
}

# Coloured get-time 
# http://stackoverflow.com/questions/138144/what-s-in-your-powershell-profile-ps1-file
function Get-Time { return $(get-date | foreach-object  { $_.ToLongTimeString() } ) }
function prompt
{
    # Write the time 
    write-host "[" -noNewLine
    write-host $(Get-Time) -foreground yellow -noNewLine
    write-host "] " -noNewLine
    # Write the path
    write-host $($(Get-Location).Path.replace($home,"~").replace("\","/")) -foreground green -noNewLine
    write-host $(if ($nestedpromptlevel -ge 1) { '>>' }) -noNewLine
    return "> "
}

# LS.MSH 
# Colorized LS function replacement 
# /\/\o\/\/ 2006 
# http://mow001.blogspot.com 
function LL
{
    param ($dir = ".", $all = $false) 

    $origFg = $host.ui.rawui.foregroundColor 
    if ( $all ) { $toList = Get-ChildItem -force $dir }
    else { $toList = Get-ChildItem $dir }

    Foreach ($Item in $toList)  
    { 
        Switch ($Item.Extension)  
        { 
            ".Exe" {$host.ui.rawui.foregroundColor = "Yellow"} 
            ".cmd" {$host.ui.rawui.foregroundColor = "Red"} 
            ".msh" {$host.ui.rawui.foregroundColor = "Red"} 
            ".vbs" {$host.ui.rawui.foregroundColor = "Red"} 
            Default {$host.ui.rawui.foregroundColor = $origFg} 
        } 
        if ($item.Mode.StartsWith("d")) {$host.ui.rawui.foregroundColor = "Green"}
        $item 
    }  
    $host.ui.rawui.foregroundColor = $origFg 
}

function lla
{
    param ( $dir=".")
    ll $dir $true
}

function la { Get-ChildItem -force }


# Shows a line to make it easy to see command inputs
$width = ($Host.UI.RawUI.WindowSize.Width - 2 - $(Get-Location).ToString().Length)
$hr = New-Object System.String @('-',$width)
Write-Host -ForegroundColor Red $(Get-Location) $hr

Set-Alias im Import-Module