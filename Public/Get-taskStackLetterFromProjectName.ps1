function Get-taskStackLetterFromProjectName{
    param(
        [parameter(mandatory)]$projectName,
        [bool]$number
    )
    write-host "Getting Octopus stack letter for $projectName..."
    $project = $projectsPage | ?{$_.Name -eq $projectName}
    if(!$project){
        throw "No project matching $projectName found!"
    }
    $targetRoles = (((Invoke-WebRequest -headers $webHeaders $octopusUrl/api/deploymentprocesses/$($project.DeploymentProcessId)).content | convertfrom-json).steps | ? Name -eq "deploy ScheduledTasks").properties.'Octopus.Action.TargetRoles'
    $targetRoles = $targetRoles -split ',' | ?{$_ -like "JobBoard-Task-Server-P*"}
    if($targetRoles.gettype().name -ne "String"){
        throw "$projectName seems to be configured on multiple stacks - $targetRoles"
    }
    $stackLetter = $targetRoles -replace "JobBoard-Task-Server-P"
    if(!$number){
        return $stackLetter
    }else{
        $stackNumber = switch($stackLetter){
            "A"{"1"};"B"{"2"};"C"{"3"};"D"{"4"};"E"{"5"};"F"{"6"};"G"{"7"};"H"{"8"};"I"{"9"};"L"{"10"};"M"{"11"};"N"{"12"};"O"{"13"};"P"{"14"};
        }
        return $stackNumber
    }
}

