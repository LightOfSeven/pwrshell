<#
Please don't use this in production, it is more to demo the random function.
#>

$password = New-Object System.Collections.ArrayList

function New-RandomPassword {
    param ()
    for ($i = 0; $i -lt 20; $i++) {
        $coinFlip = ((Get-Random) %2 -as [boolean])
        if ($coinFlip) {
            $randomNumber = Get-Random 10
            $password.Add($randomNumber)
        }
        else {
            $password.Add([char]((65..90) + (97..122) | Get-Random))
        }
    }
}

New-RandomPassword
# ArrayList kept outputting with spaces, so this removes all the whitespace characters and scrambles the string
$password = ($password -split '' | Sort-Object {Get-Random}) -join ''
$password
$password = ConvertTo-SecureString -string $password -AsPlainText -Force
$password
