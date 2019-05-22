function Get-EnvironmentIdFromName{
    param(
        [string]$environmentName
    )
    if(!($environmentName)){
        $environmentName = read-host "Enter the name of the Octopus environment to lookup"
    }

    $environmentId = ($environmentsInOctopus | ?{$_.name -eq $environmentName}).Id
   
    if(!($environmentId)){
        throw "No environment matching $environmentName found!"
    }
    return $environmentId
}

