$report = @()
$vcs = Get-Content -Path "z:\memvcenters.txt"
$creds = Get-Credential

foreach ($vc in $vcs)
{
    Connect-viserver $vc -Credential $creds
    
foreach($vm in Get-View -ViewType Virtualmachine){
 
    $vms = "" | Select-Object VMName,VMHost,Compressed,Ballooned,Swapped
 
    $vms.VMName = $vm.Name
    $vms.VMHost = Get-View -Id $vm.Runtime.Host -property Name | select -ExpandProperty Name
    $vms.Compressed = $vm.Summary.QuickStats.CompressedMemory
 $vms.Ballooned = $vm.Summary.QuickStats.BalloonedMemory
 $vms.Swapped = $vm.Summary.QuickStats.SwappedMemory
    $Report += $vms
}
$Report | export-csv -Path "z:\$vc-compressmem.csv" 
Disconnect-VIServer -Confirm:$false
$report = @()
}



