function Update-OctopusVariableSets{
    param(
        [parameter(mandatory)]$ProjectName,
        [parameter(mandatory)]$VariableSetName
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
    $variableSetId = (Get-OctopusVariableSet -VariableSetName $VariableSetName).OwnerId
    if($octoProject.IncludedLibraryVariableSetIds -notcontains $variableSetId){
        Write-Host "Updating '$projectName' to include library variable set '$variableSetId'."
        $octoProject.IncludedLibraryVariableSetIds += $variableSetId
        Invoke-WebRequest -usebasicparsing "$octopusUrl/api/projects/$($octoProject.id)" -method PUT -headers $webHeaders -Body ($octoProject | ConvertTo-Json -depth 10) | Out-Null
        Write-Host -Foreground Green "Success."
        return
    }else{
        Write-Host "'$projectName' already includes library variable set '$variableSetName'."
        return
    }
}

