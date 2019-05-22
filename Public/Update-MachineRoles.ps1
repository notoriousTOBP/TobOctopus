function Update-MachineRoles{
    param(
        [parameter(mandatory)][string]$machineName,
        [parameter(mandatory)][string]$roleName,
        [parameter(mandatory)][ValidateSet("Add","Remove")][string]$roleAction
    )
    $machineDetails = Get-OctopusMachine $machineName
    switch($roleAction){
        "Add" {
            if($machineDetails.Roles -contains $roleName){
                throw "'$machineName' already has the role '$roleName'."
            }else{
                write-host "Adding role '$roleName' to '$machineName'..."
                try{
                   $machineDetails.Roles += $roleName 
                }catch{
                    throw "Error adding role to role list - $($_.exception.message)"
                }
            }
        }
        "Remove" {
            if($machineDetails.Roles -notcontains $roleName){
                throw "'$machineName' doesn't have the role '$roleName'."
            }else{
                write-host "Removing role '$roleName' from '$machineName'..."
                try{
                   $machineDetails.Roles = $machineDetails.Roles | ?{$_ -ne $roleName}
                }catch{
                    throw "Error adding role to role list - $($_.exception.message)"
                }
            }
        }
    }
    write-host "Updating machine definition in Octopus..."
    try{
        Invoke-WebRequest -usebasicparsing -headers $webHeaders -Method "PUT" "$octopusUrl/api/Machines/$($machineDetails.Id)" -Body $($machineDetails | ConvertTo-Json -depth 10) | out-null
    }catch{
        throw "Error sending new machine definition to Octopus - $($_.exception.message)"
    }
    write-host "Success."
}

