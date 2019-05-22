function Get-OctopusProjectGroups{
    param(
        [string]$projectGroupName,
        [string]$projectGroupId
    )
    if($projectGroupName -and $projectGroupId){
        throw "Please provide -projectGroupName, -projectGroupId or neither, not both."
    }
    try{
        $allprojectGroups = Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/projectGroups/all" | convertfrom-json
    }catch{
        throw "Unable to get projectGroup details - $($_.exception.message)"
    }
    if($projectGroupName){
        $selectedprojectGroup = $allprojectGroups | ? Name -eq $projectGroupName
        if(!$selectedprojectGroup){
            throw "No projectGroup matching '$projectGroupName' found."
        }
        return $selectedprojectGroup
    }elseif($projectGroupId){
        $selectedprojectGroup = $allprojectGroups | ? Id -eq $projectGroupId
        if(!$selectedprojectGroup){
            throw "No projectGroup matching '$projectGroupId' found."
        }
        return $selectedprojectGroup
    }else{
        return $allprojectGroups
    }
}

