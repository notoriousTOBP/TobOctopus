function Remove-StepFromProjects{
    param(
        [parameter(mandatory)]$stepToRemove, # gc ~\desktop\newstep.json | convertfrom-json - Fill this variable an object detailing the step to add
        [array]$projectNames
    )
    if(!$projectNames){
        write-host "No project specified, removing step from all live projects."
        $projectsToUpdate = $projectsPage | ?{$_.ProjectGroupId -in "ProjectGroups-21","ProjectGroups-121","ProjectGroups-122"}
    }else{
        write-host "Removing step from projects specified."
        $projectsToUpdate = $projectsPage | ?{$_.Name -in $projectNames}
    }
    if(!$projectsToUpdate){
        throw "No matching projects found!"
    }
    $projectsToUpdate |%{
        write-host "Updating $($_.Name)..."
        $newProcessSteps = @()
        $processToUpdate = get-deploymentProcess $_.Name
        if($processToUpdate.steps.name -notcontains $stepToRemove){
            write-host -foreground yellow "$($_.name) doesn't have a deployment step named '$stepToRemove'"
        }else{
            $processToUpdate.steps | %{
                if($_.name -ne $stepToRemove){
                    $newProcessSteps += $_                    
                }
            }
            $processToUpdate.steps = $newProcessSteps
            write-host "Process updated.`nPosting new details to $octopusUrl..."
            try{
                $status = invoke-webrequest -ea stop "$octopusUrl/api/deploymentprocesses/$($_.DeploymentProcessId)" -Headers $webHeaders -method PUT -body $($processToUpdate | convertto-json -depth 10)
            }catch{
                write-warning "Error updating $($_.name) - $($_.exception.message)"
            }
            if($status.StatusCode -ne 200){
                write-warning "'$($_.name)' didn't return 200 - Code: $($status.Statuscode). Description: $($status.StatusDescription)."
            }
            write-host -foreground green "Done."
        }
    }
}

