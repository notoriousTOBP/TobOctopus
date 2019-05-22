function Start-OctopusTaskCleanup{
    param(
        $taskAge,
        [switch]$force
    )
    $allTasks = @()
    try{
        $webResponse = Invoke-WebRequest -usebasicparsing -ea stop -headers $webHeaders "$octopusUrl/api/tasks?active=true" | convertfrom-json
    }catch{
        throw "Error getting tasks from Octopus - $($_.exception.message)"
    }
    $allTasks += $webResponse.items
    write-host "Found $($allTasks.count) task(s)."
    while($webResponse.Links.'Page.Next'){
        try{
            $webResponse = Invoke-WebRequest -usebasicparsing -ea stop -headers $webHeaders "$octopusUrl/$($webResponse.Links.'Page.Next')" | convertfrom-json
        }catch{
            throw "Error getting releases from Octopus - $($_.exception.message)"
        }
        $allTasks += $webResponse.items
        write-host "Found $($allTasks.count) task(s)."
    }
    $tasksToTerminate = $allTasks | ?{$(get-date $_.QueueTime) -lt $((get-date).adddays(-$taskAge))}
    if(!$tasksToTerminate){
        write-host "No queued tasks over $taskAge days old found."
        return
    }
    write-host "Found $($tasksToTerminate.count) tasks that have been queued for more than $taskAge days out of $($allTasks.count) total."
    write-host "Oldest task to be terminated was created on $(get-date $tasksToTerminate[-1].QueueTime -f R)."
    write-host "Newest task to be terminated was created on $(get-date $tasksToTerminate[0].QueueTime -f R)."
    if(!$force){
        write-host "Do you want to proceed with terminating these tasks? This cannot be undone."
        if(!(Get-UserApproval)){
            return
        }
    }
    $tasksToTerminate | sort QueueTime | %{
        write-host "Terminating '$($_.Description)'..."
        Invoke-WebRequest -usebasicparsing -method POST -ea stop -headers $webHeaders $octopusUrl/$($_.links.Cancel) | out-null
    }
    write-host "Successfully terminated $($tasksToTerminate.count) tasks."
    return $tasksToTerminate.count
}

