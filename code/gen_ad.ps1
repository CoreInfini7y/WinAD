param([Parameter(Mandatory = $true)] $jsonFile)


function CreateADGroup() {
    param([Parameter(Mandatory = $true)] $groupObject)

    $groupName = $groupObject.name
    try {
        New-ADGroup -name $groupName -GroupScope Global
    }
    catch {
        write-warning "The group may already exists"
    }
}

function CreateADUser() {
    param([Parameter(Mandatory = $true)] $userObject)
    
    # Getting information from the JSON file
    $name = $userObject.name
    $password = $userObject.password

    # Generating "first initial and lastname" schema for username
    $firstName, $lastName = $name.Split(" ")
    $userName = ($firstName[0] + $lastName).tolower()
    $samAccountName = $userName
    $principalName = $userName

    # Create the AD user
    try {
        New-ADUser -Name $userName -GivenName $firstName -Surname $lastName -SamAccountname $samAccountName -UserPrincipalName $principalName@$domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) | Enable-ADAccount
    }
    catch {
        Write-Warning "The user already exists"
    }


    # Add to group(s)
    foreach ($group in $userObject.groups) {
        try {
            Add-AdGroupMember -Identity $group -Members $userName
        }
        catch [Microsodt.ActiveDirectory.Management.ADIdentityNotFooundException] {
            Write-Warning "AD group object not found"
        }
        
    }
    
}

$json = (Get-Content $jsonFile | ConvertFrom-Json)
$domain = $json.domain

foreach ($group in $json.groups) {
    CreateADGroup $group
}

foreach ($user in $json.users) {
    CreateADUser $user
}