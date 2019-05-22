function Get-OctopusProjectGroup{
    param(
        [parameter(mandatory)]$projectName,
        [switch]$getName
    )
    $octoProject = $projectsPage | ? Name -eq $projectName
    if(!$octoProject){
        throw "No project matching '$projectName' found!"
    }
    if($getName){
        Get-OctopusGroupNameFromId $octoProject.ProjectGroupId
    }else{
        return $octoProject.ProjectGroupId
    }
}

