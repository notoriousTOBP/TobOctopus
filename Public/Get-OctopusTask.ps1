function Get-OctopusTask{
    param(
        [parameter(mandatory)]$taskId
    )
    write-host "Getting task $taskId from Octopus..."
    try{
        $thisTask = Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/tasks/$taskId" | convertfrom-json
    }catch{
        throw "Error retrieving release information from Octopus - $($_.exception.message)"
    }
    if(!$thisTask){
        throw "No task found matching $taskId."
    }
    write-host "Task details successfully retrieved. Task initiated: $(get-date $thisTask.QueueTime)."
    return $thisTask
}

