function Get-OctopusMachinesByRole{
    param(
        [parameter(mandatory)]$targetRole
    )
    try{
        $allMachines = Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/Machines/all" | convertfrom-json
    }catch{
        throw "Unable to get machine details - $($_.exception.message)"
    }
    $machinesToReturn = $allMachines | ?{$_.Roles -contains $targetRole}
    return $machinesToReturn
}

