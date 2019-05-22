function Get-DeploymentProcess{
    param(
        [parameter(mandatory)]$projectName
    )
    $targetProject = $projectsPage | ?{$_.name -eq $projectName}
    write-host "Retrieving deployment process for $projectName..."
    try{
        $deployProcess = invoke-webrequest -usebasicparsing $octopusUrl/api/deploymentprocesses/deploymentprocess-$($targetProject.Id) -headers $webHeaders | convertfrom-json
    }catch{
        throw "Error retrieving the deployment process from Octopus - $($_.exception.message)"
    }
    if(!$deployProcess){
        throw "No deployment process found for $projectName."
    }
    write-host "Deployment process for $projectName retrieved successfully."
    return $deployProcess
}

