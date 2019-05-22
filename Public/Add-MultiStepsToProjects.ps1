function Add-MultiStepsToProjects{
    param(
        [parameter(mandatory)][array]$newSteps, # gc ~\desktop\newstep.json | convertfrom-json - Fill this variable with an array of step objects, in the order you'd like them to appear
        [parameter(mandatory)]$addAfterStep, # $addAfterStep needs to be the NAME of the step after which to add this new step, or START to add this step as the first step
        [array]$projectNames
    )
    if(!$projectNames){
        write-host "No project specified, adding step to all live projects."
        $projectsToUpdate = $projectsPage | ?{$_.ProjectGroupId -eq "ProjectGroups-21"}
    }else{
        write-host "Adding new step to projects specified."
        $projectsToUpdate = $projectsPage | ?{$_.Name -in $projectNames}
    }
    if(!$projectsToUpdate){
        throw "No matching projects found!"
    }
    $projectsToUpdate |%{
        write-host "Updating $($_.Name)..."
        $processToUpdate = get-deploymentProcess $_.Name
        $processToUpdate.Steps = $processToUpdate.Steps | ? Name -ne "approve deployment"
        $newSteps | %{
            $newProcessSteps = @()
            $newStep = $_
            write-host "Adding $($newStep.name)..."
            if($addAfterStep -ne "Start"){
                if($processToUpdate.steps.name -contains $newStep.name){
                    write-host -foreground yellow "$($_.name) already has a deployment step named '$($newStep.name)'"
                    $skip = $true
                }
                if($processToUpdate.steps.name -notcontains $addAfterStep){
                    write-host -foreground yellow "$($_.name) doesn't have a deployment step named '$addAfterStep'"
                    $skip = $true
                }
            }
            if(!$skip){
                if($addAfterStep -eq "Start"){
                    $newProcessSteps += $newStep
                    $processToUpdate.steps | %{
                        $newProcessSteps += $_                    
                    }    
                }else{
                    $processToUpdate.steps | %{
                        if($_.name -eq $addAfterStep){
                            $newProcessSteps += $_
                            $newProcessSteps += $newStep
                        }else{
                            $newProcessSteps += $_
                        }
                    }
                }
                $processToUpdate.steps = $newProcessSteps
                $update = $true
            }
            $skip = $null
        }
        if($update){
            try{
                $status = invoke-webrequest -ea stop "$octopusUrl/api/deploymentprocesses/$($_.DeploymentProcessId)" -Headers $webHeaders -method PUT -body $($processToUpdate | convertto-json -depth 10)
            }catch{
                write-warning "Error updating $($_.name) - $($_.exception.message)"
            }
            if($status.StatusCode -ne 200){
                write-warning "'$($_.name)' didn't return 200 - Code: $($status.Statuscode). Description: $($status.StatusDescription)."
            }
        }
        $update = $null
        write-host -foreground green "Done."
    }
}

