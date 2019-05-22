function Update-OctopusVariable{
    param(
        [parameter(mandatory)][string]$projectName,
        [parameter(mandatory)][string]$variableName,
        [parameter(mandatory)][string]$newValue,
        [array]$environmentScope = "all",
        [bool]$newValueSensitive = $false,
        [switch]$overwrite,
        [switch]$force
    )
    $environmentScopeIds = @()
    $environmentScope | ?{$_ -ne "all"}| %{
        $environmentScopeIds += get-EnvironmentIdFromName $_
    }
    $octopusProject = $projectsPage | ?{$_.name -eq $projectName}
    if(!$octopusProject){
        throw "No project named $projectName found in Octopus!"
    }
    $currentVariableSet = invoke-webrequest $octopusUrl/api/variables/$($octopusProject.VariableSetId) -headers $webHeaders -UseBasicParsing | convertfrom-json
    $oldVariables = $currentVariableSet.variables
    if($overwrite){
        if(!$force){
            Write-Warning "Specifying the 'overwrite' switch will clear all variables named '$variableName' and leave only the variable/scope specified to the cmdlet."
            if(!(Get-UserApproval)){
                return
            }
        }
        Write-Host "Removing all variables named '$variableName'..."
        $currentVariableSet.Variables = $currentVariableSet.variables | ?{$_.Name -ne $variableName}
    }
    if($environmentScope -ne "all"){
        $variableExists = $currentVariableSet.variables | ?{$_.Name -eq $variableName -and $($_.Scope.Environment | sort | out-string) -eq $($environmentScopeIds | sort | out-string)}
        if($variableExists){
            $currentVariableSet.variables | ?{$_.Name -eq $variableName -and $($_.Scope.Environment | sort | out-string) -eq $($environmentScopeIds | sort | out-string)} | %{
                Write-Host "Updating '$variableName'..."
                $_.Value = $newValue
                $_.IsSensitive = $newValueSensitive
            }
        }else{
            $environmentScopeIds | %{
                $thisEnvironmentId = $_
                if($currentVariableSet.variables | ?{$_.Name -eq $variableName -and $_.Scope.Environment -contains $thisEnvironmentId}){
                    throw "This variable already exists, scoped to a provided environment alongside one or more others. To update this variable please provide the full scope, or specify the 'overwrite' switch to remove all other instances of this variable."
                }
            }
            $currentVariableSet.variables += [PSCustomObject]@{
                Name        =   $variableName
                Value       =   $newValue
                Scope       = [PSCustomObject]@{
                    Environment = $environmentScopeIds
                }
                Type        =   "String"
                IsSensitive =   $newValueSensitive
            }
        }
    }else{
        $variableExists = $currentVariableSet.variables | ?{$_.Name -eq $variableName -and !$_.Scope.Environment}
        if($variableExists){
            $currentVariableSet.variables | ?{$_.Name -eq $variableName -and !$_.Scope.Environment} | %{
                Write-Host "Updating '$variableName'..."
                $_.Value = $newValue
                $_.IsSensitive = $newValueSensitive
            }
        }else{
            $currentVariableSet.variables += [PSCustomObject]@{
                Name        =   $variableName
                Value       =   $newValue
                Scope       = [PSCustomObject]@{
                    Environment = $environmentScopeIds
                }
                Type        =   "String"
                IsSensitive =   $newValueSensitive
            }
        }
    }
    write-host "Posting new variable set to Octopus..."
    if($oldVariables -eq $currentVariableSet.variables){
        throw "No changes have been made to the variable set! Something has gone wrong."
    }
    try{
        $putResult = invoke-webrequest -usebasicparsing $octopusUrl/api/variables/$($octopusProject.VariableSetId) -headers $webHeaders -method PUT -body $($currentVariableSet | convertto-json -depth 10)
    }catch{
        throw "Error updating $projectName variables on $octopusUrl - $($_.exception.message)"
        
    }
    if($putResult.StatusDescription -ne "OK"){
        throw "Error updating variable set for $projectName.`nStatus Description: $($putResult.StatusDescription)`nContent: $($putResult.Content)"
    }
    write-host "$variableName successfully updated!"
    return
}

