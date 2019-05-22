function Get-OctopusProject{
    param(
        [string]$projectName,
        [string]$projectGroupName
    )
    if($projectName -and $projectGroupName){
        throw "Please specify either -ProjectName or -ProjectGroupName, not both."
    }
    Update-OctopusProjectList
    if($projectName){
        $octopusProject = $projectsPage | ? Name -eq $projectName
        if(!$octopusProject){
            throw "No project matching '$projectName' found."
        }
    }elseif($projectGroupName){
        try{
            $groupDetails = Get-OctopusProjectGroups -projectGroupName $projectGroupName
        }catch{
            throw "Error getting group details - $($_.exception.message)"
        }
        $octopusProject = $projectsPage | ? ProjectGroupId -eq $groupDetails.id
        if(!$octopusProject){
            return
        }
    }else{
        $octopusProject = $projectsPage
    }
    return $octopusProject
}

