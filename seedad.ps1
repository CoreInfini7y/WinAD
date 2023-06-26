<#
$groups = get-content "./groups.txt"
$names = get-content "./names.txt"
$passwords = get-content "./passwords.txt"
$domain = "CI.tech"
$users = @{}

function CreateADGroups() {
    foreach ($group in $groups) {
        try {
            new-adgroup -name $group -samaccountname $group -GroupCategory Security -GroupScope Global -DisplayName $group
        }
        catch {
            write-warning "The $group group is already exsiting"
        }
    }
}

function GenerateUsers() {
    foreach ($user in $names) {
        $firstname, $lastname = [string]$user.split(" ")
        $userName = [string]($firstname[0] + $lastname).tolower()
        $principalname = [string]"$username@$domain"
        $password = (get-random -inputobject $passwords)
        # New-ADUser -Name "$user" -GivenName $firstname -Surname $lastname -SamAccountName $userName -UserPrincipalName $principalname -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount
        $users += $userName
        
    }
}

function AddUsers() {
    $users
    $users.length
    $users.gettype()
}

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

GenerateUsers
AddUsers
#>


# ChatGPT solution

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

# Get the total number of groups and initialize a counter
$groupCount = $groups.Count
$groupIndex = 0

DisablePP

# Iterate through the usernames and create users
for ($i = 0; $i -lt $usernames.Count; $i++) {
    $username = $usernames[$i]
    $password = Get-Random -InputObject $passwords
    $firstname, $lastname = $username.split(" ")
    $domain = "CI.tech"

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

    $user = New-ADUser @userParams
    #$user = $userParams

    # Add the user to the current group
    Add-ADGroupMember -Identity $groups[$groupIndex] -Members $user
    

    # Increment the group index in a round-robin fashion
    $groupIndex = ($groupIndex + 1) % $groupCount
}

EnablePP