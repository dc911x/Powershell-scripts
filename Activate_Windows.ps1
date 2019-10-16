$computer = gc env:computername

$key = "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"

$service = get-wmiObject -query "select * from SoftwareLicensingService" -computername $computer

$service.InstallProductKey($key)

$service.RefreshLicenseStatus()