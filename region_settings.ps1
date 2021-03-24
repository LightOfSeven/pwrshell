<# 
https://www.lewisroberts.com/2017/03/01/set-language-culture-timezone-using-powershell/
Method found from a blog post (xml) and converted into plain Powershell without the need for a separate file
Useful for SCCM Task Sequence UK Regional Settings
#>

$xml = [xml]@'
<gs:GlobalizationServices xmlns:gs="urn:longhornGlobalizationUnattend"> 
<!--User List-->
<gs:UserList>
    <gs:User UserID="Current" CopySettingsToDefaultUserAcct="true" CopySettingsToSystemAcct="true"/> 
</gs:UserList>
<!-- user locale -->
<gs:UserLocale> 
    <gs:Locale Name="en-GB" SetAsCurrent="true"/> 
</gs:UserLocale>
<!-- system locale -->
<gs:SystemLocale Name="en-GB"/>
<!-- GeoID -->
<gs:LocationPreferences> 
    <gs:GeoID Value="242"/> 
</gs:LocationPreferences>
<gs:MUILanguagePreferences>
	<gs:MUILanguage Value="en-GB"/>
	<gs:MUIFallback Value="en-US"/>
</gs:MUILanguagePreferences>
<!-- input preferences -->
<gs:InputPreferences>
    <!--en-GB-->
    <gs:InputLanguageID Action="add" ID="0809:00000809" Default="true"/> 
</gs:InputPreferences>
</gs:GlobalizationServices>
'@

& $env:SystemRoot\System32\control.exe "intl.cpl,,/f:$xml"
Set-Culture en-GB
