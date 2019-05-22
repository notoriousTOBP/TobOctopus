function Get-OctopusReleasesForProject{
    param(
        [parameter(mandatory)]$projectName
    )
    write-host "Getting all releases for '$projectName'..."
    $projectId = ($projectsPage | ? Name -eq $projectName).id
    if(!$projectId){
        throw "No project matching '$projectName' found."
    }
    $allReleases = @()
    try{
        $webResponse = Invoke-WebRequest -usebasicparsing -ea stop -headers $webHeaders "$octopusUrl/api/projects/$projectId/releases" | convertfrom-json
    }catch{
        throw "Error getting releases from Octopus - $($_.exception.message)"
    }
    $allReleases += $webResponse.items
    write-host "Found $($allReleases.count) releases."
    while($webResponse.Links.'Page.Next'){
        try{
            $webResponse = Invoke-WebRequest -usebasicparsing -ea stop -headers $webHeaders "$octopusUrl/$($webResponse.Links.'Page.Next')" | convertfrom-json
        }catch{
            throw "Error getting releases from Octopus - $($_.exception.message)"
        }
        $allReleases += $webResponse.items
        write-host "Found $($allReleases.count) release(s)."
    }
    return $allReleases
}

