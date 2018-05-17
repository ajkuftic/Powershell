# Script for KMS Cluster creation across multiple vCenters
# Author: AJ Kuftic
# Date: 5/16/2018

#Pull in list of vCenters
$vcenters = Get-content "C:\vcenters.txt"

#Set credentials
$creds = Get-Credential

#Keyfile to import for KMS Trust
$keyfile = "C:\kms.pem"

#Main loop
foreach ($vcenter in $vcenters)
{
    #Connect to vCenter
    connect-viserver $vcenter -Credential $creds
    
    #Add KMS Servers in order of use
    Add-KeyManagementServer -Address 10.1.10.10 -Port 5696 -KmsCluster Hytrust -Name "site1kms1.domain.com" -TrustKeyManagementServer $true
    Add-KeyManagementServer -Address 10.1.10.11 -Port 5696 -KmsCluster Hytrust -Name "site1kms2.domain.com" -TrustKeyManagementServer $true
    Add-KeyManagementServer -Address 10.2.10.10 -Port 5696 -KmsCluster Hytrust -Name "site2kms1.domain.com" -TrustKeyManagementServer $true
    Add-KeyManagementServer -Address 10.2.10.11 -Port 5696 -KmsCluster Hytrust -Name "site2kms2.domain.com" -TrustKeyManagementServer $true
    
    #Set up KMS trust
    Set-KmsCluster -KmsCluster Hytrust -KmsProvidedClientCertificateFilePath $keyfile -KmsProvidedPrivateKeyFilePath $keyfile -UseAsDefaultKeyProvider
}
