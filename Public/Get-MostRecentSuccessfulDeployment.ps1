function Get-MostRecentSuccessfulDeployment{
    param(
        [parameter(mandatory)]$projectName,
        [parameter(mandatory)][string]$Environment,
        [ValidateSet('quick','full')]$deploymentType
    )
    $targetProject = $projectsPage | ?{$_.name -eq $projectName}
    if($deploymentType){
        write-host "Retrieving most recent successful deployment to $environment for $projectName..."
        try{
            $successfulDeployments = (Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/deployments?projects=$($targetProject.Id)&environments=$(get-EnvironmentIdFromName $environment)&taskState=Success&limit=100" | convertfrom-json).Items
        }catch{
            throw "Error retrieving deployment information from Octopus - $($_.exception.message)"
        }
        foreach($deployment in $successfulDeployments){
            $releaseVersion = (get-octopusRelease $deployment.releaseId).version
            switch($deploymentType){
                "full"{
                    if($releaseVersion -notlike "*-quick"){
                        $successfulDeploy = $deployment    
                    }
                }
                "quick"{
                    if($releaseVersion -like "*-quick"){
                        $successfulDeploy = $deployment
                    }
                }
            }
            if($successfulDeploy){
                write-host -foreground green "$releaseVersion is a $deploymentType release."
                break
            }else{
                write-host -foreground yellow "$releaseVersion isn't a $deploymentType release."
            }
        }
    }else{
        write-host "Retrieving most recent successful deployment to $environment for $projectName..."
        try{
            $successfulDeploy = (Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/deployments?projects=$($targetProject.Id)&environments=$(get-EnvironmentIdFromName $environment)&taskState=Success&limit=1" | convertfrom-json).Items | select -first 1
        }catch{
            throw "Error retrieving deployment information from Octopus - $($_.exception.message)"
        }
    }
    if(!$successfulDeploy){
        throw "No successful deployments to $environment found for $projectName."
    }
    write-host "Last successful deployment retrieved successfully. Deployment date: $(get-date $successfulDeploy.Created)."
    return $successfulDeploy
}

