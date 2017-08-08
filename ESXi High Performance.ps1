$cluster = "Test"
$hosts = Get-Cluster -Name $cluster | Get-VMHost

#Show current settings
Write-Host "Showing current settings for $cluster cluster." -ForegroundColor Green
$hosts | Select Name,@{ N="CurrentPolicy"; E={$_.ExtensionData.config.PowerSystemInfo.CurrentPolicy.ShortName}},
@{ N="CurrentPolicyKey"; E={$_.ExtensionData.config.PowerSystemInfo.CurrentPolicy.Key}},
@{ N="AvailablePolicies"; E={$_.ExtensionData.config.PowerSystemCapability.AvailablePolicy.ShortName}} | Sort Name

#Loop to make the change to desired power management state
# 1=HighPerformance (static)
# 2=Balanced (dynamic)
# 3=LowPower (low)
# 4=Custom (custom)

foreach ($h in $hosts)
{
$view = ($h | Get-View)
Write-Host "Changing power management setting for $h." -ForegroundColor Green
(Get-View $view.ConfigManager.PowerSystem).ConfigurePowerPolicy(1)
}

#Re-list cluster to confirm setting change
Write-Host "Showing new settings for $cluster cluster." -ForegroundColor Green
$hosts | Select Name,@{ N="CurrentPolicy"; E={$_.ExtensionData.config.PowerSystemInfo.CurrentPolicy.ShortName}},
@{ N="CurrentPolicyKey"; E={$_.ExtensionData.config.PowerSystemInfo.CurrentPolicy.Key}},
@{ N="AvailablePolicies"; E={$_.ExtensionData.config.PowerSystemCapability.AvailablePolicy.ShortName}} | Sort Name