$vcenters = Get-content "C:\vcenters.txt"
$creds = Get-Credential
$keyfile = "C:\kms.pem"
foreach ($vcenter in $vcenters)
{
    connect-viserver $vcenter -Credential $creds
    Add-KeyManagementServer -Address 10.1.10.10 -Port 5696 -KmsCluster Hytrust -Name "site1kms1.domain.com" -TrustKeyManagementServer $true
    Add-KeyManagementServer -Address 10.1.10.11 -Port 5696 -KmsCluster Hytrust -Name "site1kms2.domain.com" -TrustKeyManagementServer $true
    Add-KeyManagementServer -Address 10.2.10.10 -Port 5696 -KmsCluster Hytrust -Name "site2kms1.domain.com" -TrustKeyManagementServer $true
    Add-KeyManagementServer -Address 10.2.10.11 -Port 5696 -KmsCluster Hytrust -Name "site2kms2.domain.com" -TrustKeyManagementServer $true
    Set-KmsCluster -KmsCluster Hytrust -KmsProvidedClientCertificateFilePath $keyfile -KmsProvidedPrivateKeyFilePath $keyfile -UseAsDefaultKeyProvider
}