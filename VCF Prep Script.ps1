#####################################
# VCF Host Prep Script              #
#                                   #
# Note: this assumes you have       #
# already assigned DNS entries and  #
# management IPs to the host and    #
# the hosts are connected to the    #
# network and are accessible.       #
#                                   #
#   ***Change the variables below   #
#     your specific settings!***    #
#####################################

$pass = "VMware1!"
$hostfile = "C:\VCFHosts.txt"
$ntpone = "time1.domain.com"
$ntptwo = "time2.domain.com"
$dnsone = "8.8.8.8"
$dnstwo = "8.8.4.4"
$domainname = "domain.com"


#DO NOT CHANGE BELOW THIS LINE#
$hosts = Get-Content -Path $hostfile
ForEach ($esx in $hosts) {
    Write-Host "Connecting to $esx" -ForegroundColor Green 
    Connect-VIServer -Server $esx -User root -Password $pass

    Write-Host "Configuring VM Network to VLAN $vlan on $esx" -ForegroundColor Green
    $vlan = Get-VirtualPortGroup -Name "Management Network" 
    Get-VirtualPortGroup -Name "VM Network" | Set-VirtualPortgroup -VLanID $vlan.VLanId
    
    Write-Host "Configuring DNS and Domain Name on $esx" -ForegroundColor Green
    Get-VMHostNetwork -VMHost $esx | Set-VMHostNetwork -DomainName $domainname -DNSAddress $dnsone , $dnstwo -Confirm:$false

    Write-Host "Enabling SSH on $esx" -ForegroundColor Green 
    Get-VMHostService -VMHost $esx | where{$_.Key -eq "TSM-SSH"} | Start-VMHostService -Confirm:$false

    Write-Host "Suppressing Shell Warning on $esx" -ForegroundColor Green
    Get-VMHost | Get-AdvancedSetting UserVars.SuppressShellWarning | Set-AdvancedSetting -Value 1 -Confirm:$false

    Write-Host "Configuring SSH Client Policy on $esx" -ForegroundColor Green 
    Get-VMHostService -VMHost $esx | where {$_.Key -eq "TSM-SSH"} | Set-VMHostService -policy "on" -Confirm:$false 
      
    Write-Host "Adding NTP Server $ntpone on $esx" -ForegroundColor Green 
    Add-VMHostNTPServer -NtpServer $ntpone -VMHost $esx -Confirm:$false

    Write-Host "Adding NTP Server $ntptwo on $esx" -ForegroundColor Green 
    Add-VMHostNTPServer -NtpServer $ntptwo -VMHost $esx -Confirm:$false

    Write-Host "Configuring NTP Client Policy on $esx" -ForegroundColor Green 
    Get-VMHostService -VMHost $esx | where{$_.Key -eq "ntpd"} | Set-VMHostService -policy "on" -Confirm:$false 

    Write-Host "Restarting NTP Client on $esx" -ForegroundColor Green 
    Get-VMHostService -VMHost $esx | where{$_.Key -eq "ntpd"} | Restart-VMHostService -Confirm:$false 

    Write-Host "$esx Done!" -ForegroundColor Green 
} 


