#Custom detection script
#Find the current logged on user
$explorers = Get-WmiObject -Namespace root\cimv2 -Class Win32_Process -Filter "Name='Explorer.exe'"
$explorers | ForEach-Object {
    $owner = $_.GetOwner()
    if ($owner.ReturnValue -eq 0) {
        $user = "{0}\{1}" -f $owner.Domain, $owner.User
        $oUser = New-Object -TypeName System.Security.Principal.NTAccount($user)
        $sid = $oUser.Translate([System.Security.Principal.SecurityIdentifier]).Value
    }
}

$path = "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
$name = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"

#check if the property exists
$item = Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue
if($item)
{
    Write-Host "Installed"    
}
Else {
}