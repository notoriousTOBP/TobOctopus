function Remove-OctopusVariable{
    param(
        [string]$projectName,
        [string]$variableName,
        [array]$environmentScope
    )

    if(!($projectName)){
        $projectName = read-host "Enter the name of the Octopus project to update"    
    }
    $octopusProject = $projectsPage | ?{$_.name -eq $projectName}
    if(!$octopusProject){
        return "No project named $projectName found in Octopus!"
    }
    if(!($variableName)){
        $variableName = read-host "Enter the name of the variable to delete"    
    }
    $currentVariables = invoke-webrequest $octopusUrl/api/variables/$($octopusProject.VariableSetId) -headers $webHeaders | convertfrom-json
    if(!($currentVariables.variables | ?{$_.name -eq $variableName})){
        return "No variable matching $variableName found!"
    }
    if(($currentVariables.variables | ?{$_.name -eq $variableName}).count -gt 1 -and !($environmentScope)){
        return "Multiple variables matching $variableName found, please specify the environmentScope parameter!"
    }
    $updatedVariables = @()
    write-host "Creating updated variable set, removing $variableName..."
    if($environmentScope){
        $scopeEnvId = get-EnvironmentIdFromName $environmentScope
        $currentVariables.Variables | %{
            if($_.Name -eq $variableName -and $_.Scope.Environment -eq $scopeEnvId){
                write-host "Deleting $($_.name)"
            }else{
                $updatedVariables += $_
            }
        }
    }else{
        $currentVariables.Variables | %{
            if($_.Name -eq $variableName){
                write-host "Deleting $($_.name)"
            }else{
                $updatedVariables += $_
            }
        }
    }
    $currentVariables.Variables = $updatedVariables
    write-host "New variable set created!"
    write-host "Posting new variable set to Octopus..."
    try{
        $putResult = invoke-webrequest -usebasicparsing $octopusUrl/api/variables/$($octopusProject.VariableSetId) -headers $webHeaders -method PUT -body $($currentVariables | convertto-json -depth 10)
    }catch{
        return "Error updating $projectName variables on $octopusUrl - $($_.exception.message)"
        
    }
    if($putResult.StatusDescription -ne "OK"){
        return "Error updating variable set for $projectName.`nStatus Description: $($putResult.StatusDescription)`nContent: $($putResult.Content)"
    }
    return "$variableName successfully updated!"
}

