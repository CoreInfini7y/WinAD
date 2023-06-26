# Active Directory LAB Setup

## Setup

### 01. Install Windows Server 2022 in VMware Workstation Pro 17 as a template
Install it as a Standard Server. Doesn't matter whether it's a Core or a Desktop installation, it will be handled as a 
Windows Core system.
IMPORTANT: after the VM has been created, don't forget to edit the VM settings and in Advanced Options, Enable Template Mode.

### 02. Install Windows 11 in VMware Workstation Pro 17 as a template
This one is a little bit more tricky.
Windows 11 Pro for Workstations requires disk encryption set before even finishing the setup of the VM, so it must be done.
Install the OS normally (disable all privacy related rubbish), at the account creation, DO NOT USE an online account!
Click on `Sign in options` and set `Work or school account`. Also, the computer should be set and joining to a Domain. These steps 
will preserve independency from Microsoft online services.
After theinstallation has been done, shut down the client and edit VM settings. The order is the following:
- remove encryption (this should be done on the hypervisor level)
- remove TPM hardware (this should be done on the hypervisor level)
- Enable Template Mode. (this should be done on the hypervisor level)

NOTE: install VMware Tools on both systems for simplifying your job.

### 03. Setting up the first Domain Controller
Clone the installed Windows Standard Server, start it up and make sure that all updates have been installed. Reboot.
Use `sconfig` for:
- change hostname (if needed)
- change server IP address to static
- change DNS IP to the server itself.

Use the following command to install Directory Services:
`Install-WindowsFeature AD-Domain-Services -IncludeManagementTools`

NOTE: my experience is that at least ADUC will not work if installed from any CLI - use a GUI tools instead.

Configure the server:
`Import-Module ADDSDeployment`
`Install-ADDSForest`


### 04. Setting up the first workstation
Clone the Windows 11 VM. Please note: as it is a clone, all settings are exactly the same as the original VM, so it is required to
modify the DNS settings.
`Get-DnsClientServerAddress` - this provides the interface number and the currently set DNS server address. If it's incorrect, it
will not find the Domain Controller.
`Set-DnsClientServerAddress -InterfaceIndex <index number> -ServerAddresses <DC address>` - this will set the correct DNS address.

At this time, the workstation is ready to join, so type:
`Add-Computer -DomainName <Domain FQDN> -Credential <domain\Administrator> -Force -Restart`
Upon successful join, the client will reboot. However, there is at least one thing: the computer name is still the original one
and it has to be changed. After such a change, the client must be rebooted. Type in:
`Rename-Computer -NewName "<new client name>" -DomainCredential <domain\Administrator> -Restart`

### 05. Create GPO for Powershell logging
There are two reasons for it:
- maintain some form of powershell history across sessions as it is not the default behavior
- increase security as auditing can be set for eventlog entries.

Follow these steps:
- open Group Policy Management on the DC
- right click on `Group Policy Objects`
- click `New`, name it, click `OK`
- right click the new GPO and choose `Edit...` - this opens up the Group Policy Object Editor
- click through `Computer Configuration > Administrative Templates > Windows Components > Windows PowerShell`
- Enable Module Logging, click on `Show...` and set it to "*" - this sets up Eventlog logging
- Enable Powershell Transcription and set the logging directory (by default, the user's My Documents folder is used) - this is for the transcription
- hit `Apply` and `OK`
- right click on your domain, click on `Link an Existing GPO...` and choose your newly created policy

The replication might take a while - 10-30 minutes.

### 06. Seed the AD environment with random data
To be able to do anything with this environment, it should look like a living system, therefore it is required to seed it with random data - users, groups, passwords. It can be done easily, except the passwords. The default password policy requires some sort of complexity, therefore it is required to disable it - at least temporarily. Code for disabling it:\
`secedit /export /cfg C:\Windows\Tasks\secpol.cfg`\
`(Get-Content C:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0").replace("MinimumPasswordLength = 7", "MinimumPasswordLength = 1") | Out-File C:\Windows\Tasks\secpol.cfg`\
`secedit /configure /db c:\windows\security\local.sdb /cfg C:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY`\
`rm -force C:\Windows\Tasks\secpol.cfg -confirm:$false`

Enable it again:\
`secedit /export /cfg C:\Windows\Tasks\secpol.cfg`\
`(Get-Content C:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 0", "PasswordComplexity = 1").replace("MinimumPasswordLength = 1", "MinimumPasswordLength = 7") | Out-File C:\Windows\Tasks\secpol.cfg`\
`secedit /configure /db c:\windows\security\local.sdb /cfg C:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY`\
`rm -force C:\Windows\Tasks\secpol.cfg -confirm:$false`

Another option is to use the GUI if Windows Server Desktop is installed.