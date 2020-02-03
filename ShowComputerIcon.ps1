<#
.SYNOPSIS
Shows "This PC" on the desktop.
.DESCRIPTION
This powershell script was created to be uploaded as an Intunewin application in Intune.
Packaged with Microsoft Win32 Content Prep Tool and used with the parameters shown in the example below.

To be able to change a registery entry in the HKCU of an user when the script is running in the "SYSTEM" context
we are finding the current logged on user so we can use HKEY_USER in combination with the SID.
.EXAMPLE
Showing the desktop icon(s) via intune Win32App
    Install command: powershell -ex bypass -file ShowComputerIcon.ps1
    Uninstall command: powershell -ex bypass -file ShowComputerIcon.ps1 -uninstall
Manually configure detection rules
    Use detection script: ShowComputerIconDETECTION.ps1
.NOTES
NAME: ShowComputerIcon.ps1
VERSION: 1.0
DATE: 02.02.2020
AUTHOR: Jelle Revyn (jelle.revyn.xyz)
RELEASE NOTES:
    Version 1.0: Original published version.
    Version 1.1: Added uninstall param
LINKS:
    https://www.leeejeffries.com/add-this-pc-shortcut-to-users-desktops-on-windows-server-2016
    https://batchpatch.com/deploying-a-registry-key-value-to-hkey_current_user-hkcu-or-all-users-in-hkey_users-hku
    https://gallery.technet.microsoft.com/scriptcenter/Write-to-HKCU-from-the-3eac1692#content
    https://gallery.technet.microsoft.com/scriptcenter/How-to-show-This-PC-or-7cbcfe7b/view/Discussions#content
    http://www.myotherpcisacloud.com/post/Accessing-HKEY_USERS-With-Powershell
DISCLAIMER
    The script is provided "AS IS" with no warranties
#> 

PARAM(
    [Parameter(Mandatory=$false)]
        [switch]$uninstall
)

#Find the current logged on user
$explorers = Get-WmiObject -Namespace root\cimv2 -Class Win32_Process -Filter "Name='Explorer.exe'"
$explorers | ForEach-Object {
    $owner = $_.GetOwner()
    if ($owner.ReturnValue -eq 0) {
        $user = "{0}\{1}" -f $owner.Domain, $owner.User
        $oUser = New-Object -TypeName System.Security.Principal.NTAccount($user)
        $sid = $oUser.Translate([System.Security.Principal.SecurityIdentifier]).Value
        #Write-Verbose ('Writing registry values for current user: {0}' -f $user) -Verbose
    }
}

#PSDrive only maps HKLM & HKCU so need to use Microsoft.PowerShell.Core\Registry::HKEY_USERS
#Registry key path set to HKEY_USER with SID (S-1-5-21-.....) instead of of HKCU user otherwise it won't run in a SYSTEM context.
$path = "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"

#Property name
$name = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"

#Check if its an uninstall or install and set the registeryvalue as it should | 0 = show - 1 = hide
if($uninstall){
    $installationvalue = 1
} else {
    $installationvalue = 0
}

#check if the property exists
$item = Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue
if($item)
{
    #set property value
    Set-ItemProperty -Path $path -name $name -Value $installationvalue 
}
Else
{
    #create a new property
    New-ItemProperty -Path $path -Name $name -Value $installationvalue -PropertyType DWORD | Out-Null 
}

#Registery key set but you need to refresh the desktop to show it.

$code = @'
  [System.Runtime.InteropServices.DllImport("Shell32.dll")] 
  private static extern int SHChangeNotify(int eventId, int flags, IntPtr item1, IntPtr item2);

  public static void Refresh()  {
      SHChangeNotify(0x8000000, 0x1000, IntPtr.Zero, IntPtr.Zero);    
  }
'@

Add-Type -MemberDefinition $code -Namespace WinAPI -Name Explorer 
[WinAPI.Explorer]::Refresh()

 