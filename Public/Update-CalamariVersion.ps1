function Update-CalamariVersion{
    param(
        [parameter(mandatory)][array]$targetMachines,
        [parameter(mandatory)][ValidateSet("octopussy","octopodes","thekraken","squid")][string]$octopusServer,
        [switch]$monitorProgress
    )
    if($octopusServer -ne $currentTargetServer){
        Set-OctopusServer $octopusServer
    }
    
    $machineIds = @()
    $targetMachines | %{
        $thisName = $_
        $machineIds += $serversInOctopus | %{if($_.name -eq $thisName){$_.Id}}
    }
    if(!($machineIds)){
        throw "Unable to get machine ID from names provided - $targetMachines"
    }
    
    write-host -nonewline "Updating Calamari on"
    $targetMachines | %{
        write-host -foreground cyan -nonewline " $_"
    }
    write-host "."
    $taskToPost = [PSCustomObject]@{
        Name        =   "UpdateCalamari"
        Description =   "Update Calamari on Deployment Targets"
        Arguments   =   [PSCustomObject]@{
            MachineIds = $machineIds
        }
    }
    try{
        $taskRun = invoke-webrequest -usebasicparsing $octopusUrl/api/tasks -headers $webHeaders -method POST -body $($taskToPost | convertto-json -depth 10) | convertfrom-json
    }catch{
        throw "Error posting the task run to Octopus - $($_.exception.message)"
    }
    if($monitorProgress){
        if(!(Watch-TaskProgress $taskRun.Id 1)){
            throw "Task run failed!"
        }
    }
    return $taskRun
}

