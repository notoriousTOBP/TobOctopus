function Update-ProjectGroup{
    param(
        [parameter(mandatory)]$projectName,
        [parameter(mandatory)]$projectGroup
    )
    $targetProject  =   $projectsPage | ?{$_.name -eq $projectName}
    if(!$targetProject){
        throw "No project matching '$projectName' found in Octopus."
    }
    $projectGroups  =   invoke-webrequest -usebasicparsing $octopusUrl/api/projectgroups/all -headers $webHeaders | convertfrom-json
    $targetGroup    =   $projectGroups | ?{$_.name -eq $projectGroup}
    if(!$targetGroup){
        throw "No project group found matching '$projectGroup'."
    }
    if($targetProject.ProjectGroupId -eq $targetGroup.Id){
        write-host -foreground yellow "'$projectName' is already in the '$projectGroup' project group."
    }else{
        write-host "Moving '$projectName' to the '$projectGroup' project group..."
        $targetProject.ProjectGroupId = $targetGroup.Id
        write-host "Sending the updated deployment process to Octopus..."
        try{
            $putResult = invoke-webrequest -usebasicparsing $octopusUrl/api/projects/$($targetProject.Id) -headers $webHeaders -method PUT -body $($targetProject | convertto-json -depth 10)
        }catch{
            throw "Error updating '$projectName' project group on $octopusUrl - $($_.exception.message)"   
        }
        write-host "'$projectName' moved to the '$projectGroup' project group successfully."
    }
}

