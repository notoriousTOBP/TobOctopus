function Get-AllOctopusPackages{
    write-host "Getting all packages from '$currentTargetServer'..."
    
    $allPackages = @()
    try{
        $webResponse = Invoke-WebRequest -usebasicparsing -ea stop -headers $webHeaders "$octopusUrl/api/packages" | convertfrom-json
    }catch{
        throw "Error getting releases from Octopus - $($_.exception.message)"
    }
    $allPackages += $webResponse.items
    write-host "Found $($allPackages.count) package(s)."
    while($webResponse.Links.'Page.Next'){
        try{
            $webResponse = Invoke-WebRequest -usebasicparsing -ea stop -headers $webHeaders "$octopusUrl/$($webResponse.Links.'Page.Next')" | convertfrom-json
        }catch{
            throw "Error getting releases from Octopus - $($_.exception.message)"
        }
        $allPackages += $webResponse.items
        write-host "Found $($allPackages.count) package(s)."
    }
    return $allPackages
}

