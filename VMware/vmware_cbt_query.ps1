#Requires -Module VMware.PowerCLI

# Check if we're connected to a vCenter
if(-not $global:DefaultVIServer){
   Connect-vCenter
}

# Find all VM snapshots on the vCenter Server
$Report = Get-VM | Get-Snapshot | Select VM,Name,Description,@{Label="Size";Expression={"{0:N2} GB" -f ($_.SizeGB)}},Created
If (-not $Report){  
   $Report = New-Object PSObject -Property @{
      VM = "No snapshots found on any VM's controlled by $VIServer"
      Name = ""
      Description = ""
      Size = ""
      Created = ""
   }
}
$Report = $Report | Select VM,Name,Description,Size,Created

$Output = New-Object System.Collections.Generic.List[System.Object]

# Query the API for CBT information and pass an output object to the pipeline / CLI
ForEach($Item in $Report){
   $VMView = Get-VM -Name $Item.VM.Name | Get-View
   $Snapshot = (Get-Snapshot -VM $Item.VM.Name) | Get-View
   $CBTQuery = $VMView.QueryChangedDiskAreas($Snapshot.MoRef, 2000, 0, "*")
   $Object = New-Object -TypeName PSObject
   $Object | Add-Member -MemberType NoteProperty -Name "VM Name" -Value $Item.VM.Name
   $Object | Add-Member -MemberType NoteProperty -Name "VM Host" -Value $Item.VM.VMHost
   $Object | Add-Member -MemberType NoteProperty -Name "VM Size" -Value $Item.VM.UsedSpaceGB
   $Object | Add-Member -MemberType NoteProperty -Name "Snapshot Created" -Value $Item.Created
   $Object | Add-Member -MemberType NoteProperty -Name "Snapshot Size" -Value $Item.Size
   $Object | Add-Member -MemberType NoteProperty -Name "Snapshot Description" -Value $Item.Description
   $Object | Add-Member -MemberType NoteProperty -Name "Snapshot Reference" -Value $Snapshot.MoRef.Value
   $Object | Add-Member -MemberType NoteProperty -Name "CBT Offset" -Value $CBTQuery.StartOffset
   $Object | Add-Member -MemberType NoteProperty -Name "CBT Length" -Value $CBTQuery.Length
   $Output.Add($Object)
}
$Output
