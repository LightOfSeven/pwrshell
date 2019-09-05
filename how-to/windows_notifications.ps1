#### This is the windows form "ok!" prompt

$Message = "Test message!"
cmd.exe "/C msg.exe * $Message"



#### This is the toast notification in the corner for Windows 10 / bubble in Windows7

Add-Type -AssemblyName  System.Windows.Forms 
$global:balloon = New-Object System.Windows.Forms.NotifyIcon

[void](Register-ObjectEvent  -InputObject $balloon  -EventName MouseDoubleClick  -SourceIdentifier IconClicked  -Action {

  #Perform  cleanup actions on balloon tip

  $global:balloon.dispose()

  Unregister-Event  -SourceIdentifier IconClicked

  Remove-Job -Name IconClicked

  Remove-Variable  -Name balloon  -Scope Global

}) 

$path = (Get-Process -id $pid).Path
$balloon.Icon  = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balloon.BalloonTipIcon  = [System.Windows.Forms.ToolTipIcon]::Warning
$balloon.BalloonTipText  = 'What do you think of this balloon tip?'
$balloon.BalloonTipTitle  = "Attention  $Env:USERNAME" 
$balloon.Visible  = $true 
$balloon.ShowBalloonTip(5000) 



#### This is the windows form 'yes / no / cancel' with an error symbol

Add-Type -AssemblyName PresentationFramework
$msgBoxInput =  [System.Windows.MessageBox]::Show('Would you like to play a game?','Game  input','YesNoCancel','Error')
switch($msgBoxInput){
	'Yes' {
	## Do something 
	}
	'No' {
	## Do something
	}
	'Cancel' {
	## Do something
	}
}
