function Remove-OctopusRelease{
    param(
        [parameter(mandatory)]$releaseId,
        [switch]$force
    )
    
    if(!(Get-OctopusRelease $releaseId)){
        throw "No release matching '$releaseId' found."
    }
    $projectUrl = "$octopusUrl/api/releases/$releaseId"
    if(!$force){
        write-host "Proceeding will remove the release '$releaseId' from Octopus - this cannot be undone."
        if(!(Get-UserApproval)){
            return
        }
    }
    write-host "Deleting '$releaseId'..."
    try{
        Invoke-WebRequest -usebasicparsing -ea stop -method DELETE -headers $webHeaders $projectUrl | out-null
    }catch{
        throw "Error removing release - $($_.exception.message)"
    }
    write-host "Done."
    return
    
}

