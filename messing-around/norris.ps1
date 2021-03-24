$Computer = "Computer-Name-Here"
While($true){
	Start-Sleep (Get-Random -Minimum 20 -Maximum 40)
	Invoke-Command -ComputerName $Computer -ScriptBlock {
		$Message = (Invoke-RestMethod -Uri 'https://api.chucknorris.io/jokes/random').Value
		cmd.exe "/C msg.exe * $Message"
	}
}
