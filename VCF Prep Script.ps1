#####################################
# VCF Host Prep Script              #
#                                   #
# Note: this assumes you have       #
# already assigned DNS entries and  #
# management IPs to the host and    #
# the hosts are connected to the    #
# network and are accessible.       #
#                                   #
#####################################


$pass = "VMware1!"
$hostfile = "C:\VCFHosts.txt"
$ntpone = "time1.domain.com"
$ntptwo = "time2.domain.com"

#DO NOT CHANGE BELOW THIS LINE#
$hosts = Get-Content -Path $hostfile
ForEach ($esx in $hosts) {
    Write-Host "Connecting to $esx" -ForegroundColor Green 
    Connect-VIServer -Server $esx -User root -Password $pass

    Write-Host "Enabling SSH on $esx" -ForegroundColor Green 
    Get-VMHostService -VMHost $esx | where{$_.Key -eq "TSM-SSH"} | Start-VMHostService -Confirm:$false

    Write-Host "Configuring SSH Client Policy on $esx" -ForegroundColor Green 
    Get-VMHostService -VMHost $esx | where {$_.Key -eq "TSM-SSH"} | Set-VMHostService -policy "on" -Confirm:$false 

    Write-Host "Remove NTP Servers on $esx" -ForegroundColor Green 
    $allNTPList = Get-VMHostNtpServer -VMHost $esx
    Remove-VMHostNtpServer -VMHost $esx -NtpServer $allNTPList -Confirm:$false | out-null
        
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


