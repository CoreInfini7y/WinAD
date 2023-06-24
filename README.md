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
- remove encryption (this can be done on the hypervisor level)
- remove TPM hardware
- Enable Template Mode.

NOTE: install VMware Tools on both systems for simplifying your job.

### 03. Setting up the first Domain Controller
Clone the installed Windows Standard Server, start it up and make sure that all updates have been installed. Reboot.
Use `sconfig` for:
- change hostname (if needed)
- change IP address to static
- change DNS IP to the server itself.

Use the following command to install Directory Services:
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools