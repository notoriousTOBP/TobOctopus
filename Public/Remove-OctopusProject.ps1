function Remove-OctopusProject{
    param(
        [parameter(mandatory)]$projectName,
        [switch]$force
    )
    $projectId = ($projectsPage | ? Name -eq $projectName).id
    if(!$projectId){
        throw "No project matching '$projectName' found."
    }
    $projectUrl = "$octopusUrl/api/projects/$projectId"
    if(!$force){
        write-host "Proceeding will remove the '$projectName' project from Octopus - this cannot be undone."
        if(!(Get-UserApproval)){
            return
        }
    }
    write-host "Deleting '$projectName'..."
    try{
        Invoke-WebRequest -usebasicparsing -ea stop -method DELETE -headers $webHeaders $projectUrl | out-null
    }catch{
        throw "Error removing project - $($_.exception.message)"
    }
    write-host "Done."
    return
    
}

