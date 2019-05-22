function Get-WebStackLetterFromProjectName{
    param(
        [parameter(mandatory)]$projectName
    )
    write-host "Getting Octopus stack letter for $projectName..."
    $project = $projectsPage | ?{$_.Name -eq $projectName}
    if(!$project){
        throw "No project matching $projectName found!"
    }
    $targetRoles = (((Invoke-WebRequest -headers $webHeaders $octopusUrl/api/deploymentprocesses/$($project.DeploymentProcessId)).content | convertfrom-json).steps | ? Name -eq "deploy sites").properties.'Octopus.Action.TargetRoles'
    $targetRoles = $targetRoles -split ',' | ?{$_ -match "JobBoard-Project-Web-Stack-(EU|NA)"}
    if($targetRoles.gettype().name -ne "String"){
        throw "$projectName seems to be configured on multiple stacks - $targetRoles"
    }
    $stackLetter = $targetRoles -replace "JobBoard-Project-Web-Stack-(EU|NA)-"
    return $stackLetter
}

