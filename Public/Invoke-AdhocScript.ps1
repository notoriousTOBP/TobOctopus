function Invoke-AdhocScript{
    param(
        [parameter(mandatory)][string]$script,
        [parameter(mandatory)][array]$targetMachines,
        [bool]$noWait
    )
    $taskName = "AdHocScript"
    $taskDescription = "Script run from Powershell - target machines:"
    $targetMachines | %{
        $taskDescription += "`n$($_)"
    }
    $scriptSyntax = "PowerShell"
    $machineIds = @()
    $targetMachines | %{
        $thisName = $_
        $machineIds += $serversInOctopus | %{if($_.name -eq $thisName){$_.Id}}
    }
    if(!($machineIds)){
        return "Unable to get machine ID from names provided - $targetMachines"
    }
    $post = [PSCustomObject]@{
        Name = $taskName
        Description = $taskDescription
        Arguments = [PSCustomObject]@{
            ScriptBody = $script 
            Syntax = $scriptSyntax
            MachineIds = $machineIds
        }
    }
    # Post the 'adhocscript' task to Octopus, keep the result in a variable so we have the task ID to check the status of the task
    $postResult = Invoke-WebRequest -contentType "application/json" $octopusUrl/api/tasks -Method POST -Body $($post | convertto-json) -Headers $webHeaders
    if($postResult.StatusCode -ne 201){
        return "POST failed"
    }
    $taskId = ($postResult | convertfrom-json).Id
    if($noWait){
        write-host -foreground cyan "`nScript posted successfully with task ID '$taskId'"
        return
    }
    # Keep checking the state of the task until it either completes or fails
    while($taskResult.task.state -ne "Success"){
        $taskResult = ((Invoke-WebRequest -contentType "application/json" $octopusUrl/api/tasks/$taskid/details -Headers $webHeaders).content | convertfrom-json)
        Write-Host -foreground cyan "Task status: $($taskResult.task.state)"
        if($taskResult.task.state -eq "Failed"){
            write-host -foreground red "`nTask run failed.`n"
            $taskResult.ActivityLog.Children | %{
                write-host "`nOutput from $($_.Name)`n`n$($_.LogElements.MessageText)`n"
            }
            throw "An error occurred when running the adhoc script. See $octopusUrl/app#/tasks/$taskid"
        }
        sleep 2
    }
    write-host -foreground green "`nTask run complete.`n"
    $finalResults = @()
    $taskResult.ActivityLogs.Children | %{
        $serverResult = New-Object PSObject
        $serverResult | add-member -type NoteProperty "Server" $($_.Name -replace "Run script on: ","") # Bit of string manipulation to get the server name from the log
        $serverResult | add-member -type NoteProperty "Response" $($_.LogElements.MessageText | ?{$_ -ne "Exit code: 0" -and $_ -ne "This Tentacle is currently busy performing a task that cannot be run in conjunction with any other task. Please wait..." -and $_ -notlike "*this task cannot be run in conjunction with any other tasks*"}) # Provided the exit code is 0 (You won't reach this step if it's not) we don't need it in our sorted output
        $finalResults += $serverResult
    }
    return $finalResults
}

