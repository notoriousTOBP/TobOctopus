function Update-OctopusMachineConfig{
    param(
        [parameter(mandatory)][string]$targetHostName,
        [array]$targetEnvironments,
        [array]$targetRoles,
        $portNumber = 10933,
        [switch]$replace
    )
    try{
        $ipAddress = (Resolve-DnsName -ea stop $serverName).Ipaddress
    }catch{
        throw "Error getting instance IP address - $($_.exception.message)"
    }
    try{
        $targetEndpointThumbprint = (Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/machines/discover?host=$ipAddress&type=TentaclePassive"  -ea stop | convertfrom-json).Endpoint.Thumbprint
    }catch{
        throw "Unable to contact '$targetHostName' from Octopus Deploy - $($_.exception.message)"
    }
    if(!($serversInOctopus | ? Name -eq $targetHostName)){
        write-host "'$targetHostName' isn't currently configured in Octopus. Registering with new details..."
        $machineDetails = [PSObject]@{
            Endpoint        =   [PSObject]@{
                CommunicationStyle  =   "TentaclePassive"
                Thumbprint          =   $targetEndpointThumbprint
                Uri                 =   "https://$($ipAddress):$($portNumber)/"
            }
            Status          =   "Unknown"
            MachinePolicyId =   "MachinePolicies-2"
            Name            =   $targetHostName.tolower()
            EnvironmentIds  =   @()
            Roles           =   @()
        }
        $method = "POST"
    }else{
        write-host "'$targetHostName' is currently configured in Octopus. Updating registered roles and environments..."
        $machineId              =   get-octopusMachineIdFromServerName $targetHostName
        $machineDetails         =   Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/machines/$machineId" -ea stop | convertfrom-json
        $originalEnvironments   =   $machineDetails.EnvironmentIds
        $originalRoles          =   $machineDetails.Roles
        $method = "PUT"
    }

    if($replace){
        if($targetEnvironments.count -ne 0){
            $machineDetails.EnvironmentIds = @()
            $targetEnvironments | %{
                $environmentId = get-EnvironmentIdFromName $_
                $machineDetails.EnvironmentIds += $environmentId
            }
        }
        if($targetRoles.count -ne 0){
            $machineDetails.Roles = $targetRoles
        }
    }else{
        $targetEnvironments | %{
            $environmentId = get-EnvironmentIdFromName $_
            if($environmentId -notin $machineDetails.EnvironmentIds){
                $machineDetails.EnvironmentIds += $environmentId
            }
        }
        $targetRoles | %{
            if($_ -notin $machineDetails.Roles){
                if($_){
                    $machineDetails.Roles += $_
                }
            }
        }
    }
    if(($machineDetails.Roles -eq $originalRoles) -and ($machineDetails.EnvironmentIds -eq $originalEnvironments)){
        return "No changes to make!"
        
    }
    try{
        Invoke-WebRequest -usebasicparsing -method $method -headers $webHeaders "$octopusUrl/api/machines/$machineId" -body $($machineDetails | convertto-json -depth 10) -ea stop | out-null
    }catch{
        throw "Error posting new infomation to Octopus Deploy - $($_.exception.message)"
    }
    $global:serversInOctopus = Invoke-WebRequest -Headers $webHeaders $octopusUrl/api/machines/all | convertfrom-json
    write-host "'$targetHostName' successfully updated on '$octopusUrl'."
    return
}

