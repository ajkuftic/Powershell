# CSV with vCenter, DVS, IP Prefix and gateway 
$inputfile = "vcenters.csv"

# Import the CSV 
$vcenters = Import-CSV $inputfile

#Get credentials from user
$creds = Get-Credential

#Set portgroup
$pg = "NFS"

#Set counter for last octet of NFS IP
$i = 100

# Set destination subnets to be cleared out of routing
$destIpList1 = ('10.10.1.0')
$destIpList2 = ('10.10.2.0')

#Set NFS targets. 
$nfspath1 = "/ISO"
$nas1 = "nas.domain.com"
$nfspath2 = "/Patches"
$nas2 = "nas.domain.com"

#Begin loop through vCenters
foreach ($vcenter in $vcenters) {
#Set variables from imported CSV
    $vc = $($vcenter.vcenter)
    $vSwitch = $($vcenter.vswitch)
    $prefix = $($vcenter.prefix)
    $gateway = $($vcenter.gateway)

#Connect to vCenter
    connect-viserver $vc -Credential $creds
#Grab all of the hosts
    $hosts = Get-VMHost

#Loop through all of the hosts found
    foreach ($h in $hosts)
        {
        # Get the vSwitch information
        $vss = Get-VirtualSwitch -VMHost $h -Name $vSwitch
        #Create new NFS IP vmk
        New-VMHostNetworkAdapter -VMHost $h -VirtualSwitch $vss -PortGroup $pg -IP "$prefix.$i" -SubnetMask 255.255.255.0
        #Increment counter
        $i++
        #Get any existing routes
        $route1 = Get-VMHostRoute -VMHost $h | where {$destIpList1 -contains $_.Destination.IPAddressToString}
        $route2 = Get-VMHostRoute -VMHost $h | where {$destIpList2 -contains $_.Destination.IPAddressToString}
        #Remove existing routes
        Remove-VMHostRoute -VMHostRoute $route1 -Confirm:$false
        Remove-VMHostRoute -VMHostRoute $route2 -Confirm:$false
        #Print routes (this should reply null)
        $route1
        $route2
        #Create new routes
        New-VMHostRoute -VMHost $h -Destination 10.10.1.0 -PrefixLength 24 -Gateway $gateway -Confirm:$false
        New-VMHostRoute -VMHost $h -Destination 10.10.2.0 -PrefixLength 24 -Gateway $gateway -Confirm:$false
        #Mount NFS volumes
        New-Datastore -Nfs -VMhost $h -Name ISO -Path $nfspath1 -NfsHost $nas1
        New-Datastore -Nfs -VMhost $h -Name Patches -Path $nfspath2 -NfsHost $nas2
        }
    #Disconnect from vCenter without requiring input
    disconnect-viserver -Confirm:$false
}
