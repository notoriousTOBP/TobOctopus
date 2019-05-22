function Get-MostRecentDeploymentState{
    param(
        [parameter(mandatory)]$projectName,
        [ValidateSet('quick','full')]$deploymentType,
        [parameter(mandatory)]$environment
    )
    $targetProject = $projectsPage | ?{$_.name -eq $projectName}
    if($deploymentType){
        write-host "Retrieving most recent deployment to $environment for $projectName..."
        try{
            $allDeployments = (Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/deployments?projects=$($targetProject.Id)&environments=$(get-EnvironmentIdFromName $environment)&limit=100" | convertfrom-json).Items
        }catch{
            throw "Error retrieving deployment information from Octopus - $($_.exception.message)"
        }
        foreach($deployment in $allDeployments){
            $releaseVersion = (get-octopusRelease $deployment.releaseId).version
            switch($deploymentType){
                "full"{
                    if($releaseVersion -notlike "*-quick"){
                        $recentDeploy = $deployment    
                    }
                }
                "quick"{
                    if($releaseVersion -like "*-quick"){
                        $recentDeploy = $deployment
                    }
                }
            }
            if($recentDeploy){
                break
            }else{
                write-host -foreground yellow "$releaseVersion isn't a $deploymentType release."
            }
        }
    }else{
        write-host "Retrieving most recent deployment to $environment for $projectName..."
        try{
            $recentDeploy = (Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/deployments?projects=$($targetProject.Id)&environments=$(get-EnvironmentIdFromName $environment)&limit=1" | convertfrom-json).Items | select -first 1
            $releaseVersion = (get-octopusRelease $recentDeploy.releaseId).version
        }catch{
            throw "Error retrieving deployment information from Octopus - $($_.exception.message)"
        }
    }
    if(!$recentDeploy){
        throw "No recent deployments to $environment found for $projectName."
    }
    try{
        $taskState = (get-OctopusTask $recentDeploy.taskId).State
    }catch{
        throw "Error retrieving task information from Octopus - $($_.exception.message)"
    }
    write-host "Last deployment retrieved successfully. Deployment date: $(get-date $recentDeploy.Created)."
    return [PSCustomObject]@{
        ProjectName         =   $projectName
        DeploymentTime      =   $(get-date $recentDeploy.Created)
        DeploymentVersion   =   $releaseVersion
        ReleaseId           =   $recentDeploy.releaseId
        DeploymentResult    =   $taskState
    }
}

