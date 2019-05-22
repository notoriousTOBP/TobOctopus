function Update-OctopusActionTemplateUsage{
    param(
        [parameter(mandatory)]$ActionTemplateId
    )
    try{
        $templateUsage = Invoke-WebRequest -usebasicparsing -headers $webHeaders -Uri "$octopusUrl/api/ActionTemplates/$actionTemplateId/usage" | ConvertFrom-Json
    }catch{
        throw "Error getting current template usage - $($_.exception.message)"
    }
    $latestVersion = (Get-OctopusActionTemplates -ActionTemplateId $actionTemplateId).Version
    $updateActionBody = @{
        actionIdsByProcessId = [PSCustomObject]@{
            "deploymentprocess-$($octoProject.id)" = @(
                $action.id
            )
        }
        defaultPropertyValues   =   @{}
        overrides               =   @{}
        version                 =   $latestVersion
    }
    foreach($deployProcess in $templateUsage){
        $updateActionBody.actionIdsByProcessId | Add-Member $deployProcess.DeploymentProcessId @($deployProcess.ActionId)
    }
    Write-Host "Updating all deployment processes to use version $latestVersion of $actionTemplateId..."
    try{
        Invoke-WebRequest -usebasicparsing -headers $webHeaders -method POST "$octopusUrl/api/ActionTemplates/$actionTemplateId/actionsUpdate" -Body $($updateActionBody | ConvertTo-Json -depth 10) | Out-Null
        Write-Host -foreground green "Success."
    }catch{
        throw "Error updating $($action.Name) - $($_.exception.message)"   
    }
}

