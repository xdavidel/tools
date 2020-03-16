# Commands and parameters
$cmd = 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe'
$listprm = 'list vms'
$runvm = 'startvm'

# List all VMs
$out = Invoke-Expression "& '$cmd' $listprm"

# Get VMs names
$found = [regex]::Matches($out, '".*?"').Value -replace '"'

# Prompt VM Choice
$Title = "Virtualbox VMs"
$Info = "Choose a VM to run"
$options = [System.Management.Automation.Host.ChoiceDescription[]] @($found)
[int]$defaultchoice = 0

try {
    $opt = $host.UI.PromptForChoice($Title , $Info , $Options,-1)
        if ("$opt" -ne -1) { 
        # Run machine
        $choice = $found[$opt]
        Invoke-Expression "& '$cmd' $runvm $choice"
    }
} catch [Management.Automation.Host.PromptingException] {}