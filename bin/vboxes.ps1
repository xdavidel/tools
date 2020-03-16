# Commands and parameters
$cmd = 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe'
$listprm = 'list vms'
$runvm = 'startvm'

# List all VMs
$chosen = Invoke-Expression "& '$cmd' $listprm" | ConvertFrom-String -PropertyNames VirtualMachineName,Hash -Delimiter " " | Out-GridView -OutputMode "Single"

# Safeguard
if ($chosen -Eq $null) {exit}

# Run selected machine
Invoke-Expression "& '$cmd' $runvm $chosen.VirtualMachineName"