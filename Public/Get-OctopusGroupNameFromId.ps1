function Get-OctopusGroupNameFromId{
    param(
        [parameter(mandatory)]$projectGroupId
    )
    try{
        $projectGroupName = (Invoke-WebRequest -usebasicparsing $octopusUrl/api/projectgroups/$projectGroupId -headers $webHeaders | ConvertFrom-Json).Name
    }catch{
        throw "Error getting project group name - $($_.exception.message)"
    }
    if($projectGroupName){
        return $projectGroupName
    }else{
        throw "No name found for $projectGroupId."
    }
}

