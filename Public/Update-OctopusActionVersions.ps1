function Update-OctopusActionVersions{
    param(
        [parameter(mandatory)]$projectName
    )
    try{
        Update-OctopusProjectList
    }catch{
        throw "Error updating project list - $($_.exception.message)"
    }
    $octoProject = $projectsPage | ? Name -eq $projectName
    if(!$octoProject){
        throw "No project matching '$projectName' found."
    }
    try{
        $stepsUsingTemplates = (Get-DeploymentProcess $projectName).Steps | ?{$_.Actions.Properties.'Octopus.Action.Template.Id'}
    }catch{
        throw "Error finding steps using templates - $($_.exception.message)"
    }
    foreach($step in $stepsUsingTemplates){
        foreach($action in ($step.Actions | ?{$_.Properties.'Octopus.Action.Template.Id'})){
            Write-Host "Updating $($action.Name)..."
            try{
                Write-Host "Current version: $($action.Properties.'Octopus.Action.Template.Version')"
                $latestVersion = (Get-OctopusActionTemplates -ActionTemplateId $action.Properties.'Octopus.Action.Template.Id').Version
                Write-Host "Latest version: $latestVersion"
            }catch{
                throw "Error getting latest version of $($action.Name) - $($_.exception.message)"
            }
            $updateActionBody = @{
                actionIdsByProcessId = @{
                    "deploymentprocess-$($octoProject.id)" = @(
                        $action.id
                    )
                }
                defaultPropertyValues   =   @{}
                overrides               =   @{}
                version                 =   $latestVersion
            }
            try{
                Invoke-WebRequest -usebasicparsing -headers $webHeaders -method POST "$octopusUrl/api/ActionTemplates/$($action.Properties.'Octopus.Action.Template.Id')/actionsUpdate" -Body $($updateActionBody | ConvertTo-Json -depth 10) | Out-Null
                Write-Host -foreground green "Success."
            }catch{
                throw "Error updating $($action.Name) - $($_.exception.message)"   
            }
        }
    }
}

