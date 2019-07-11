#requires -RunAsAdministrator
Try{
    Uninstall-Module -Name AWSPowershell
    Install-Module -Name AWSPowershell -AllowClobber -SkipPublisherCheck -Force
}
Catch{
    Write-Error "$_"
}
