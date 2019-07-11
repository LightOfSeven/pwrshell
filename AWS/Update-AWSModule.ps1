#requires -RunAsAdministrator
Try{
    if(-not (Get-Module AWSPowershell){
        Install-Module -Name AWSPowershell -AllowClobber -SkipPublisherCheck -Force
    else{
        Uninstall-Module -Name AWSPowershell
        Install-Module -Name AWSPowershell -AllowClobber -SkipPublisherCheck -Force
    }
}
Catch{
    Write-Error "$_"
}
