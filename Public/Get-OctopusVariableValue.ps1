function Get-OctopusVariableValue{
    param(
        [parameter(mandatory)][string]$projectName,
        [array]$variableName,
        [string]$environmentScope,
        [switch]$returnVarName
    )
    $octopusProject = $projectsPage | ?{$_.name -eq $projectName}
    if(!$octopusProject){
        throw "No project named '$projectName' found in Octopus."
    }
    try{
        $currentVariables   =   invoke-webrequest $octopusUrl/api/variables/$($octopusProject.VariableSetId) -headers $webHeaders | convertfrom-json
    }catch{
        throw "Error getting variable set for '$projectName' - $($_.exception.message)"
    }
    if($variableName){
        if($environmentScope){
            $scopeEnvId     =   Get-EnvironmentIdFromName $environmentScope
            $targetVariable =   $currentVariables.Variables | ?{$_.Name -in $variableName -and $_.scope.environment -contains $scopeEnvId}
        }else{
            $targetVariable     =   $currentVariables.Variables | ?{$_.Name -in $variableName}
        }
        if(!$targetVariable){
            throw "No '$variableName' variable found on $projectName project."
        }
        if($returnVarName){
            return $($targetVariable | Select-Object Name,Value)
        }else{
            return $targetVariable.Value
        }
    }else{
        return $currentVariables
    }
}

