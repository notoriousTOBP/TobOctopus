function New-OctopusDeployment{
    param(
        [parameter(mandatory)]$releaseId,
        [parameter(mandatory)]$environmentName,
        [array]$skipActions,
        [array]$targetMachineIds,
        [bool]$monitorProgress
    )
    $newDeployment = new-object psObject -property @{
        ReleaseId           =   $releaseId
        EnvironmentId       =   $(get-EnvironmentIdFromName $environmentName)
        SkipActions         =   $skipActions
        SpecificMachineIds  =   $targetMachineIds
    }
    write-host "Triggering a deployment of $releaseId to $environmentName..."
    try{
        $deploymentRun = invoke-webrequest -usebasicparsing $octopusUrl/api/deployments -headers $webHeaders -method POST -body $($newDeployment | convertto-json -depth 10) | convertfrom-json
    }catch{
        throw "Error posting the deployment run to Octopus - $($_.exception.message)"
    }
    if($monitorProgress){
        while($state -ne "Success"){
            if($state -eq "Failed"){
                throw "Deployment failed, aborting."
            }
            Write-host "Deploying..."
            start-sleep -s 10
            $state = (Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/tasks/$($deploymentRun.taskId)" | convertfrom-json).state
            write-host -foreground yellow "Current task state is: $state"
        }
        write-host "Deploy of $releaseId to $environmentName complete."
    }else{
        write-host "Deploy of $releaseId to $environmentName successfully triggered."
    }
    return
}

