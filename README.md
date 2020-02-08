# Powershell-scripts

- [Powershell-scripts](#powershell-scripts)
  - [General](#general)
    - [Activate_Windows.ps1](#activatewindowsps1)
    - [W10-Setup_for_new_devices.ps1](#w10-setupfornewdevicesps1)
  - [Intune](#intune)
    - [Make_useradmin_on_device.ps1](#makeuseradminondeviceps1)
    - [Install-GoogleChromeExtensions.ps1](#install-googlechromeextensionsps1)
    - [ShowComputerIcon.ps1](#showcomputericonps1)
    - [AllowNon-AdministratorsToInstallPrinterDrivers.ps1](#allownon-administratorstoinstallprinterdriversps1)

## General

### Activate_Windows.ps1
Simple script to activate Windows using Powershell.
Adjust the X's on line 3 with your Key.

Note: Script could be pushed with Intune (Device configuraiton -> PowerShell scripts) but I would not recommend it as the full powershell script gets saved to the intune management extension logs. For more information check out Oliver Kieselbach's [part 1](https://oliverkieselbach.com/2017/11/29/deep-dive-microsoft-intune-management-extension-powershell-scripts/) & [part 2](https://oliverkieselbach.com/2018/02/12/part-2-deep-dive-microsoft-intune-management-extension-powershell-scripts/) about Inutne mangement extions powershell scripts.

### W10-Setup_for_new_devices.ps1
Simple script for cleaning up a fresh Windows 10:
  * Sets keyboard lay-out
  * Remove default apps (Except Windows Store)
  * Unpins all-apps from start-menu

## Intune

### Make_useradmin_on_device.ps1
Simplified powershell script from [Michael Mardahl](https://gist.github.com/mardahl) for my organisation for adding AZUREAD/people to the local administrator group.

**Usage:**
- Create security group in Azure Active Directory and add the people you want to give local administrator rights.
- Go to Device configuration - Powershell scripts and add "Make_useradmin_on_device.ps1"
  - Run as system
  - Don't enforce signature check
  - Assign the group created in the first step to the script.

**Why:**

Intune only let's you add a local administrator to ALL devices. 
I originaly searched for something like this because I made my autopilot group a standard user and I already deployed a few devices before I noticed and didn't want to recall the devices.

- [Docs microsoft: assign local admin](https://docs.microsoft.com/en-us/azure/active-directory/devices/assign-local-admin)
- [SCConfigMgr way](https://www.scconfigmgr.com/2018/08/30/configure-restricted-groups-with-intune-policy-csp/)
- [Uservoice Q to change this](https://feedback.azure.com/forums/169401-azure-active-directory/suggestions/31914520-utilize-aad-security-groups-for-device-additional)

Special Thanks to [Michael Mardahl](https://gist.github.com/mardahl), full script [here](https://gist.github.com/mardahl/062c15f863be9232b9c1953e34b660f8).
Article explaining his full script [here](https://www.iphase.dk/local-administrators-on-aad-joined-devices/).

### Install-GoogleChromeExtensions.ps1

[ublock origin in this example]

This is Martin Bengtsson's work please visit his [blog's article](https://www.imab.dk/install-google-chrome-extensions-using-microsoft-intune/) for understanding this script and the usage.

### ShowComputerIcon.ps1
They asked me to set "This PC" on the desktop, I couldn't find any options to do this in Intune and most script just put a shortcut on the desktop where you still needed to fiddle with icon's etc...

You can use the ".intunewin" file or package it yourself with Microsoft Win32 Content Prep Tool.

Showing the desktop icon via intune Win32App

```
Upload ShowComputerIcon.intunewin 
Install command: powershell -ex bypass -file ShowComputerIcon.ps1
Uninstall command: powershell -ex bypass -file ShowComputerIcon.ps1 -uninstall
```

Manually configure detection rules
```
Use detection script: ShowComputerIconDETECTION.ps1
```

### AllowNon-AdministratorsToInstallPrinterDrivers.ps1
This is a translation of a well known GPO ("Allow non-administrators to install drivers for these device setup classes") under 
"Computer Configuration -> Policies -> Administrative Templates -> System -> Driver Installation" to be used with intune.
AFAIK this is the only way to set this policy as no Configuration profile is availble, not even a custom OMA-URI.

Via intune Win32App
```
    Install command: powershell -ex bypass -file AllowNon-AdministratorsToInstallPrinterDrivers.ps1
    Uninstall command: powershell -ex bypass -file AllowNon-AdministratorsToInstallPrinterDrivers.ps1 -uninstall
```

Manually configure detection rules
```
    Manually configure detection rules:
    - Rule type: Registery
    - Key path: HKLM:\Software\Policies\Microsoft\Windows\DriverInstall\Restrictions\AllowUserDeviceClasses\
    - Value name: printer
    - Detection method: Key exists
```
