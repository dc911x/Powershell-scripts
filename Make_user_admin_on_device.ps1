Function Add-localAdmin(){
    
    <#
    .SYNOPSIS
    This function is used to add a specified UPN to the built-in Administrators group
    .DESCRIPTION
    The function connects generates the required commandline required in order to add an Azure AD account to a local group, and handle any errors.
    IF all goes well, the user is added to the group.
    The fucntion will also validate agains existing members, to avoid generating errors.
    .EXAMPLE
    Get-AADGroupMembers -UPN user@domain.tld -Name "Display Name"
    .NOTES
    NAME: Add-LocalAdmin
    PREREQUISITES: Requires elevation
    #>
       
    param
    (
        [Parameter(Mandatory=$true)]
        $UPN,
        [Parameter(Mandatory=$true)]
        $Name
    )

    try {
        
        #Validating agains existing members
        
        #Formatting the correct commandline, and executing it.        
        $commandline = 'net localgroup administrators'
        $currentMembers = & cmd.exe /c "$commandline"
        #Special way of catching an error in the cmd and turning it into a terminating error.
        if ($LASTEXITCODE -ne 0) { throw }
        #Removing spaces from the users display name, and comparing agains current members.
        $noSpaceName = $Name -replace '\s',''
        $found = $currentMembers | select-string -Pattern $noSpaceName
        if ($found.count -gt 0) {
            Write-Host "Found $found, in the built-in Administrators group. Skipping..." -ForegroundColor Yellow
            continue
        }

        #Adding users, since validation seems to have passed

        Write-Host "Adding $Name <$UPN> to the built-in Administrators group." -ForegroundColor Yellow
        
        #Formatting the correct commandline, and executing it.        
        $commandline = 'net localgroup administrators /add "AzureAD\{0}"' -f $UPN
        & cmd.exe /c "$commandline"
        #Special way of catching an error in the cmd and turning it into a terminating error.
        if ($LASTEXITCODE -ne 0) { throw }

    }
    
    catch {
    
        Write-Host "Failed adding $Name <$UPN> to the built-in Administrators group." -ForegroundColor Red
        continue
    
    }

}

#Finding out the current logged in user and splitting into "User" and "Domain" since the script already accounts for the AzureAD domain

[String] ${stUserDomain},[String] ${stUserAccount} = $(Get-WMIObject -class Win32_ComputerSystem | select username).username.split("\")

#Adding the current logged in user to local Administrators group

Add-localAdmin -UPN $stUserAccount -Name $stUserAccount