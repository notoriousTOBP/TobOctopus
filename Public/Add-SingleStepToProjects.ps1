function Add-SingleStepToProjects{
    param(
        [parameter(mandatory)]$newStep, # gc ~\desktop\newstep.json | convertfrom-json - Fill this variable an object detailing the step to add
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
        $newProcessSteps = @()
        $processToUpdate = get-deploymentProcess $_.Name

        $webServerRole = (($processToUpdate.steps | ?{$_.name -eq "update IIS"}).Properties.'Octopus.Action.TargetRoles'.split(',') | ?{$_ -match "^JobBoard-Project-Web-Server-P[A-Z]$"})
        if(!$webServerRole){
            throw "No matching 'project-web-server' role found."
        }
        write-host "Assigned web stack for '$($_.Name)' is '$webServerRole'"
        $newStep.Properties.'Octopus.Action.TargetRoles' = "JobBoard-Project-Web-Server,$webServerRole"
        
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
        $skip = $null
    }
}

