# Script to copy file to all hosts and run commands.
# This example is for mass changing IPMI IPs from the CLI
#
# NOTE: Requires darkoperator PoshSSH for PowerShell
#
# To install PoshSSH:
# Install-Module -Name Posh-SSH -Scope CurrentUser
# 
# If the SSH commands error with "Exception has been thrown by the target of an invocation", you need to disable FIPS compliance
# Do this from an elevated command line: "reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\FipsAlgorithmPolicy" /v Enabled /t REG_DWORD /d 0 /f"

# CSV with host IP, password, and BMC IP
$inputfile = "D:\ipmitool\IPlist.csv"

# Import the CSV 
$target = Import-CSV $inputfile

# Set ESX user
$esxuser = "root"
 
# Location to find the ipmitool binary:
$source_file = "D:\ipmitool\ipmitool"
 
$target_path = "/tmp/"
 
# Location to copy ipmitool to on ESXi hosts:
$target_file = "/tmp/ipmitool"

#Set Expected output:
$ipmitooloutput = "IP Address  "

Foreach ($node in $target) {

#Sets up variables from the input CSV
$hostip = $($node.hostip)
$pw = $($node.pwd)
$bmcip = $($node.bmcip)

# Converts the password from plain text in the CSV to SecureString
$pass = $pw | ConvertTo-SecureString -AsPlainText -Force

# Creates a credential variable
$credESXi = New-Object -TypeName "System.Management.Automation.PSCredential"($esxuser,$pass)

# Initiates the SSH session
$ssh = New-SSHSession -ComputerName $hostip -Credential $credESXi -Port 22 -AcceptKey:$true

# Pulls the hostname
$return = Invoke-SSHCommand -SSHSession $ssh -Command "uname -a"
Write-Host "Host ID: " + $return.Output -ForegroundColor Yellow

# Copy the ipmitool utility to the host:
Write-Host "- Copying binary file" -ForegroundColor Green
$scp = Set-SCPFile -ComputerName $_ -Credential $credESXi -Port 22 -LocalFile $source_file -RemotePath $target_path

# And flag it as executable:
Write-Host "- Changing execute mode" -ForegroundColor Green
Invoke-SSHCommand -SSHSession $ssh -Command "chmod 'u+x' $target_file" | Out-Null

# Attempts to set IP 
Write-Host "Setting IPMI IP Attempt 1:" -ForegroundColor Green
Invoke-SSHCommand -SSHSession $ssh -Command "/tmp/ipmitool lan -U admin -P password set 1 ipaddr $bmcip"

# Sets IP
Write-Host "Setting IPMI IP Attempt 2:" -ForegroundColor Green
Invoke-SSHCommand -SSHSession $ssh -Command "/tmp/ipmitool lan -U admin -P password set 1 ipaddr $bmcip"

# Attempts to grab the output. Poorly.
Write-Host "Setting IPMI IP Attempt 1:" -ForegroundColor Green
Invoke-SSHCommand -SSHSession $ssh -Command "/tmp/ipmitool lan print 1 | grep $ipmitooloutput"

# Disconnects the SSH Session
Remove-SSHSession -SSHSession $ssh | Out-Null
}
