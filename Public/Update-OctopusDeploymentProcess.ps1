function Update-OctopusDeploymentProcess{
    param(
        [parameter(mandatory)]$projectName,
        [parameter(mandatory)][ValidateSet('container','lambda')]$projectType
    )
    $deploymentStepsPath = "$env:temp\ClonedRepos\microservices\delivery\octopus\deploymentprocess-$projectType.json"
    try{
        Update-OctopusProjectList
    }catch{
        throw "Error updating project list - $($_.exception.message)"
    }
    if(!($projectsPage | ? Name -eq $projectName)){
        throw "No project matching '$projectName' found."
    }
    try{
        $currentProcess         =   Get-DeploymentProcess $projectName
    }catch{
        throw "Error getting current deployment process - $($_.exception.message)"
    }
    try{
        $processConfig        =   (Get-Content $deploymentStepsPath | ConvertFrom-Json).Steps
    }catch{
        throw "Error importing deployment template - $($_.exception.message)"
    }
    $currentProcess.Steps   =   @()
    foreach($stepName in $processConfig.Name){
        Write-Host "Adding $stepName..."
        try{
            $currentProcess.Steps += (Get-Content "$env:temp\ClonedRepos\microservices\delivery\octopus\steps\$stepName.json" | ConvertFrom-Json)
            Write-Host -foreground green "Success."
        }catch{
            throw "Error adding $stepName to deployment process - $($_.exception.message)."
        }
    }
    try{
        Invoke-WebRequest -usebasicparsing "$octopusUrl/api/deploymentprocesses/$($currentProcess.Id)" -method PUT -headers $webHeaders -Body ($currentProcess | ConvertTo-Json -depth 10) | Out-Null
        Write-Host -Foreground green "Process update success."
    }catch{
        throw "Error posting new deployment process - $($_.exception.message)"
    }
}

