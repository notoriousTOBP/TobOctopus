function Get-OctopusRelease{
    param(
        [parameter(mandatory)]$releaseId
    )
    write-host "Getting release $releaseId from Octopus..."
    try{
        $thisRelease = Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/releases/$releaseId" | convertfrom-json
    }catch{
        throw "Error retrieving release information from Octopus - $($_.exception.message)"
    }
    if(!$thisRelease){
        throw "No release found matching $releaseId."
    }
    write-host "Release details successfully retrieved. Release asembled: $(get-date $thisRelease.assembled)."
    return $thisRelease
}

