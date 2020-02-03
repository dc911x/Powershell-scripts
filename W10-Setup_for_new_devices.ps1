<#   
.DESCRIPTION
    Windows 10 clean-up script
    * Sets keyboard lay-out
    * Remove default apps (Except Windows Store)
    * Unpins all-apps from start-menu
.NOTES
    Filename: W10-Setup_for_new_devices.ps1
    Version: 1.0    
#>

#Run as administrator
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

#Set Keyboard lay-out
Write-Host "Set keyboard lay-out to nl_BE."
$1 = New-WinUserLanguageList nl-BE
Set-WinUserLanguageList $1 -Confirm:$false -Force

#Remove all default apps (not Windows Store)
Write-Host "Remove all default apps except Windows Store"
Get-AppXPackage -AllUsers | where-object {$_.name -notlike "*store*"} | Remove-AppxPackage -ErrorAction 'silentlycontinue'

function Pin-App { param([string]$appname, [switch]$unpin)
  try{
    if ($unpin.IsPresent){
      ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'From "Start" UnPin|Unpin from Start'} | %{$_.DoIt()}
      return "App '$appname' unpinned from Start"
    }else{
      ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'To "Start" Pin|Pin to Start'} | %{$_.DoIt()}
      return "App '$appname' pinned to Start"
    }
  }catch{
  }
}

#Unpin All Apps
foreach ( $item in $layoutfile.LayoutModificationTemplate.DefaultLayoutOverride.StartLayoutCollection.StartLayout.Group.DesktopApplicationTile.DesktopApplicationLinkPath) {
  $outputFile = Split-Path $item -leaf
  $name = $outputFile.split('.') | Select-Object -first 1
  Pin-App "$name" -unpin     
}

#Quit
Write-Host "Press any key to continue..."
$null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")