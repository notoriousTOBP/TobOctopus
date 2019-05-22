function Get-OctopusMachine{
    param(
        [parameter(mandatory)][string]$machineName
    )
    $machineId = Get-OctopusMachineIdFromServerName $machineName
    try{
        $machineDetail = Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/Machines/$machineId" | convertfrom-json
    }catch{
        throw "Unable to get details for $machineId - $($_.exception.message)"
    }
    return $machineDetail
}

