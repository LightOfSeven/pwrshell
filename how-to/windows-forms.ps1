<#
.SYNOPSIS 
- An example of Windows Forms
#>


Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
$OUs                             = "Text Here"
$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '567,121'
$Form.text                       = "Form"
$Form.TopMost                    = $false
$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 199
$TextBox1.height                 = 20
$TextBox1.location               = New-Object System.Drawing.Point(178,26)
$TextBox1.Font                   = 'Microsoft Sans Serif,10'
$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "New Computer Name"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(42,30)
$Label1.Font                     = 'Microsoft Sans Serif,10'
$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "Domain Join"
$Button1.width                   = 99
$Button1.height                  = 30
$Button1.location                = New-Object System.Drawing.Point(393,20)
$Button1.Font                    = 'Microsoft Sans Serif,10'
$Button1.Add_Click{ Add-Computer -NewName "$($TextBox1.text)" -domainname "$env:UserDomain" -OUPath "$($ComboBox1.text)" -Credential (Get-Credential) }
$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "Choose OU"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(43,59)
$Label2.Font                     = 'Microsoft Sans Serif,10'
$ComboBox1                       = New-Object system.Windows.Forms.ComboBox
$ComboBox1.text                  = "Choose OU"
$ComboBox1.width                 = 198
$ComboBox1.height                = 20
$ComboBox1.location              = New-Object System.Drawing.Point(178,56)
$ComboBox1.Font                  = 'Microsoft Sans Serif,10'
$ComboBox1.Items.AddRange($OUs)
$Button2                         = New-Object system.Windows.Forms.Button
$Button2.text                    = "Restart"
$Button2.width                   = 99
$Button2.height                  = 30
$Button2.location                = New-Object System.Drawing.Point(393,61)
$Button2.Font                    = 'Microsoft Sans Serif,10'
$Button2.Add_Click{ Restart-Computer }
$Form.controls.AddRange(@($TextBox1,$Label1,$Button1,$Label2,$ComboBox1,$Label,$Button2))
$form.ShowDialog()
