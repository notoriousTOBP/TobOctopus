function Remove-OctopusMachine{
    param(
        [parameter(mandatory)][string]$machineName
    )
    if($machineName -match "^Machines-[0-9]{1,10}$"){
        Write-Warning "'$machineName' seems to be a machine ID rather than a computer name. Proceeding with that assumption."
        $machineId = $machineName
    }else{
        $machineId = Get-OctopusMachineIdFromServerName $machineName
    }
    if(!$machineId){
        throw "No machine ID found for '$machineName'."
    }
    try{
        $machineDelete = Invoke-WebRequest -usebasicparsing -method "DELETE" -headers $webHeaders "$octopusUrl/api/Machines/$machineId" | convertfrom-json
    }catch{
        throw "Error removing computer '$machineName' with ID '$machineId' from Octopus Deploy - $($_.exception.message)"
    }
    write-host "'$machineName' removed successfully."
    return
}

