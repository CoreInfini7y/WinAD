# Import the Active Directory module
Import-Module ActiveDirectory

function DisablePP() {
    secedit /export /cfg C:\Windows\Tasks\secpol.cfg
    (Get-Content C:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0").replace("MinimumPasswordLength = 7", "MinimumPasswordLength = 1") | Out-File C:\Windows\Tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg C:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    rm -force C:\Windows\Tasks\secpol.cfg -confirm:$false
}

function EnablePP() {
    secedit /export /cfg C:\Windows\Tasks\secpol.cfg
    (Get-Content C:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 0", "PasswordComplexity = 1").replace("MinimumPasswordLength = 1", "MinimumPasswordLength = 7") | Out-File C:\Windows\Tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg C:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    rm -force C:\Windows\Tasks\secpol.cfg -confirm:$false
}



# Set the file paths for usernames, passwords, and groups
$usernamesFile = ".\names.txt"
$passwordsFile = ".\passwords.txt"
$groupsFile = ".\groups.txt"

# Read the content of the files
$usernames = Get-Content $usernamesFile
$passwords = Get-Content $passwordsFile
$groups = Get-Content $groupsFile

DisablePP

# Create the groups
foreach ($group in $groups) {
    New-ADGroup -Name $group -GroupScope Global
}

# Get the total number of groups and initialize a counter
$groupCount = $groups.Count

# Iterate through the usernames and assign users to groups randomly
for ($i = 0; $i -lt $usernames.Count; $i++) {
    $username = $usernames[$i]
    $password = Get-Random -InputObject $passwords
    $firstname, $lastname = $username.split(" ")
    $domain = "citech.local"
    
    # Create the user
    $userParams = @{
        SamAccountName = ($firstname[0] + $lastname).tolower()
        UserPrincipalName = "$($username.Replace(' ', ''))@$domain"
        Name = $username
        GivenName = $username.Split(" ")[0]
        Surname = $username.Split(" ")[1]
        AccountPassword = (ConvertTo-SecureString -String $password -AsPlainText -Force)
        Enabled = $true
    }

    try {
        $user = New-ADUser @userParams
        write-output "User created: $($userParams['SamAccountName'])"
    }
    catch {
        write-output "Failed to create user: $username"
        write-output "Error: $_"
    }

    # Get a random group index
    $groupIndex = Get-Random -Minimum 0 -Maximum $groupCount

    # Add the user to the randomly selected group
    Add-ADGroupMember -Identity $groups[$groupIndex] -Members $($userParams['SamAccountName'])
    
}

EnablePP