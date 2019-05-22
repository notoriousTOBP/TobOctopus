function Get-OctopusMachineIdFromServerName{
    param(
        [parameter(mandatory)]$serverName
    )
    $machineId = $serversInOctopus | ? Name -eq $serverName
    if(!$machineId){
        throw "No server matching '$serverName' found in Octopus."
    }
    write-host "'$serverName' has the ID '$($machineId.Id)'"
    return $machineId.Id
}

