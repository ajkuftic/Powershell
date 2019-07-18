# Set variables
$report = @()

# Pull in vCenters from list
$vcs = Get-Content -Path "C:\memvcenters.txt"

# Collect credentials to use across the vCenters
$creds = Get-Credential

# Connect to vCenter
foreach ($vc in $vcs)
{
    Connect-viserver $vc -Credential $creds

# Pull VM data
foreach($vm in Get-View -ViewType Virtualmachine){
 
    $vms = "" | Select-Object VMName,VMHost,Compressed,Ballooned,Swapped
 
    $vms.VMName = $vm.Name
    $vms.VMHost = Get-View -Id $vm.Runtime.Host -property Name | select -ExpandProperty Name
    $vms.Compressed = $vm.Summary.QuickStats.CompressedMemory
 $vms.Ballooned = $vm.Summary.QuickStats.BalloonedMemory
 $vms.Swapped = $vm.Summary.QuickStats.SwappedMemory
    if ($vms.Compressed){
    $Report += $vms
    }
}

# Generate report
$Report | export-csv -Path "C:\$vc-compressmem.csv" 

# Disconnect from vCenter
Disconnect-VIServer -Confirm:$false

# Clear array so it doesn't continually append
$report = @()
}



