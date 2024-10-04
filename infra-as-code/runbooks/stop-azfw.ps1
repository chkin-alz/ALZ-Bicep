Param(
    [string]$resourceGroupName,
    [string]$azFwName,
 #   [string]$VMName,
    [string]$Method,
 #   [string]$UAMI,
    [string]$subscriptionId
)

#$automationAccount = "xAutomationAccount"

# Ensures you do not inherit an AzContext in your runbook
$null = Disable-AzContextAutosave -Scope Process

# Connect using a Managed Service Identity
try {
    $AzureConnection = (Connect-AzAccount -Identity).context
}
catch {
    Write-Output "There is no system-assigned user identity. Aborting." 
    exit
}

# set and store context
#$AzureContext = Set-AzContext -SubscriptionId $subscriptionId -DefaultProfile $AzureConnection
Set-AzContext -SubscriptionId $subscriptionId -DefaultProfile $AzureConnection

if ($Method -eq "SA") {
    Write-Output "Using system-assigned managed identity"
}
elseif ($Method -eq "UA") {
    Write-Output "Using user-assigned managed identity"

# Connects using the Managed Service Identity of the named user-assigned managed identity
#    $identity = Get-AzUserAssignedIdentity -ResourceGroupName $ResourceGroup -Name $UAMI -DefaultProfile $AzureContext

# validates assignment only, not perms
#    $AzAutomationAccount = Get-AzAutomationAccount -ResourceGroupName $ResourceGroup -Name $automationAccount -DefaultProfile $AzureContext
#    if ($AzAutomationAccount.Identity.UserAssignedIdentities.Values.PrincipalId.Contains($identity.PrincipalId)) {
#        $AzureConnection = (Connect-AzAccount -Identity -AccountId $identity.ClientId).context

# set and store context
#        $AzureContext = Set-AzContext -SubscriptionName $AzureConnection.Subscription -DefaultProfile $AzureConnection
#    }
#    else {
#        Write-Output "Invalid or unassigned user-assigned managed identity"
#        exit
#    }
}
else {
    Write-Output "Invalid method. Choose UA or SA."
    exit
}


$azfw = Get-AzFirewall -Name $azFwName -ResourceGroupName $resourceGroupName

if($azfw.IpConfigurations.Count -gt 0) {
    Write-Output "Stopping Azure Firewall $azFwName"
    $azfw.Deallocate()
    Set-AzFirewall -AzureFirewall $azfw
} 
# if($azfw.ProvisioningState -eq "Succeeded") {
#     Write-Output "Stopping Azure Firewall $azFwName"
#     $azfw.Deallocate()
#     Set-AzFirewall -AzureFirewall $azfw
# } 
else {
    Write-Output "$azFwName not running...terminating script"
}

<# # Get current state of VM
$status = (Get-AzVM -ResourceGroupName $ResourceGroup -Name $VMName -Status -DefaultProfile $AzureContext).Statuses[1].Code

Write-Output "`r`n Beginning VM status: $status `r`n"

# Start or stop VM based on current state
if ($status -eq "Powerstate/deallocated") {
    Start-AzVM -Name $VMName -ResourceGroupName $ResourceGroup -DefaultProfile $AzureContext
}
elseif ($status -eq "Powerstate/running") {
    Stop-AzVM -Name $VMName -ResourceGroupName $ResourceGroup -DefaultProfile $AzureContext -Force
}

# Get new state of VM
$status = (Get-AzVM -ResourceGroupName $ResourceGroup -Name $VMName -Status -DefaultProfile $AzureContext).Statuses[1].Code

Write-Output "`r`n Ending VM status: $status `r`n `r`n"

Write-Output "Account ID of current context: " $AzureContext.Account.Id #>