function Update-OctopusProject{
    param(
        [parameter(mandatory)]$projectName,
        [string]$projectGroupName = "All projects"
    )
    $thisScriptName         =   Split-Path $PSCommandPath -leaf
    $projectTemplatePath    =   "$env:temp\ClonedRepos\microservices\delivery\octopus\project.json"
    try{
        $projectConfig = Get-Content $projectTemplatePath | ConvertFrom-Json
    }catch{
        throw "Error importing config template - $($_.exception.message)"
    }
    try{
        Update-OctopusProjectList
    }catch{
        throw "Error updating project list - $($_.exception.message)"
    }
    if(($projectsPage | ? Name -eq $projectName)){
        $currentProject = $projectsPage | ? Name -eq $projectName
        Write-Host "Updating $projectName..."
        try{
            Invoke-WebRequest -usebasicparsing "$octopusUrl/api/projects/$($currentProject.id)" -method PUT -headers $webHeaders -Body ($projectConfig | ConvertTo-Json -depth 10) | Out-Null
            Write-Host -Foreground green "Success."
        }catch{
            throw "Error updating project - $($_.exception.message)"
        }
    }else{
        Write-Host "Creating $projectName..."
        try{
            $projectDescription     =   "**$projectGroupName** sub product created by **$env:username** using function *$($myinvocation.mycommand.name)* from module *$thisScriptName* on **$(get-date -f u)**."
            $projectGroupId         =   (Get-OctopusProjectGroups -projectGroupName $projectGroupName).Id
            $lifecycleId            =   (Get-OctopusLifecycles -lifecycleName 'Microservices').Id                
            $projectConfig.Name             =   $projectName
            $projectConfig.Slug             =   $projectName
            $projectConfig.Description      =   $projectDescription
            $projectConfig.LifecycleId      =   $lifecycleId
            $projectConfig.ProjectGroupId   =   $projectGroupId
            Invoke-WebRequest -usebasicparsing "$octopusUrl/api/projects" -method POST -headers $webHeaders -Body ($projectConfig | ConvertTo-Json -depth 10) | Out-Null
            Write-Host -Foreground green "Success."
        }catch{
            throw "Error creating new project - $($_.exception.message)"
        }
        if($projectGroupName -ne "All projects"){
            Write-Host "Updating variable sets..."
            try{
                Update-OctopusVariableSets -ProjectName $projectName -VariableSetName "Microservices Variables - $projectGroupName"
            }catch{
                throw "Error updating variable sets - $($_.exception.message)"
            }
        }
    }
}

