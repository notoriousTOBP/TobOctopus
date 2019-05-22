function Get-EnvironmentNameFromId{
    param(
        [string]$environmentId
    )
    if(!($environmentId)){
        $environmentId = read-host "Enter the ID of the Octopus environment to lookup"
    }
  
    $environmentName = ($environmentsInOctopus | ?{$_.Id -eq $environmentId}).name
   
    if(!($environmentName)){
        throw "No environment matching $environmentId found!"
    }
    return $environmentName
}

