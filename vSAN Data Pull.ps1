$vcenters = Get-Content "vcenters.txt"
$cred = Get-Credential

foreach ($vc in $vcenters)
{
    $output = "$vc.txt"
    Connect-VIServer $vc -Credential $cred
    $hosts = get-vmhost
    foreach ($h in $hosts)
    {
        $esxcli = get-esxcli -VMHost $h -V2
        $h 1>> $output
        $esxcli.vsan.cluster.get.invoke() 1>> $output
        $esxcli.vsan.storage.list.invoke() | select DisplayName,InCMMDS 1>> $output

    }
}
