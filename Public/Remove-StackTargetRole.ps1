function Remove-StackTargetRole{
    param(
        [parameter(mandatory)]$projectName,
        [parameter(mandatory)][validateset("JobBoard-Project-Web-Server","JobBoard-DB-Updater","JobBoard-Task-Server")]$targetRole,
        [parameter(mandatory)]$targetOctoStackLetter
    )
    $targetOctoStackLetter = $targetOctoStackLetter.toUpper()
    $targetProject = $projectsPage | ?{$_.name -eq $projectName}
    write-host "Getting current deployment process for $projectName..."
    $currentProcess = Invoke-WebRequest -usebasicparsing -headers $webHeaders $octopusUrl$($targetProject.links.deploymentProcess) | convertfrom-json
    if(!($currentProcess.steps.properties.'Octopus.Action.TargetRoles' | ?{$_ -match "$targetRole-P$targetOctoStackLetter"})){
        throw "$targetRole-P$targetOctoStackLetter isn't included in the deployment process for $projectName."
    }
    $oldProcess     = $currentProcess
    write-host "Updating process to remove stack '$targetOctoStackLetter' for target role '$targetRole'"
    $currentProcess.steps | ?{$_.properties.'Octopus.Action.TargetRoles' -match $targetRole} | %{
        $_.properties.'Octopus.Action.TargetRoles' = $_.properties.'Octopus.Action.TargetRoles' -replace ",$targetRole-P$targetOctoStackLetter"
    }
    if(($currentProcess.steps.properties.'Octopus.Action.TargetRoles' | ?{$_ -match $targetRole}) -eq ($oldProcess.steps.properties.'Octopus.Action.TargetRoles' | ?{$_ -match $targetRole})){
        throw "No changes were made to the deployment process, something has gone wrong."
    }
    write-host "Sending the updated deployment process to Octopus..."
    try{
        $putResult = invoke-webrequest -usebasicparsing $octopusUrl/api/deploymentprocesses/$($targetProject.deploymentProcessId) -headers $webHeaders -method PUT -body $($currentProcess | convertto-json -depth 10)
    }catch{
        throw "Error updating $projectName deployment process on $octopusUrl - $($_.exception.message)"
        
    }
    if($putResult.StatusDescription -ne "OK"){
        throw "Error updating deployment process for $projectName.`nStatus Description: $($putResult.StatusDescription)`nContent: $($putResult.Content)"
    }
    write-host "$projectName deployment process successfully updated!"
    return
}

