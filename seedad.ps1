
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