function New-OctopusRelease{ #WIP - currently creates a new release at the same version of the release given as a parameter, for moving between stacks
    param(
        [parameter(mandatory)]$releaseToUse
    )
    <#if($releaseToUse.version -like "*move*"){
        throw "Most recent deploy was a stack move release."
    }
    $releaseChannels = get-OctopusChannelsForProject ($projectsPage | ?{$_.id -eq $releaseToUse.ProjectId}).Name
    if($releaseToUse.ChannelId -eq ($releaseChannels | ? Name -eq "master-full-auto").Id){
        write-host "Most recent release was 'master-full-auto' - switching to 'master-full'"
        $releaseToUse.ChannelId = ($releaseChannels | ? Name -eq "master-full").Id
    }#>
    $newRelease = new-object psObject -property @{
        ProjectId           =   $releaseToUse.projectId
        ChannelId           =   $releaseToUse.ChannelId
        SelectedPackages    =   $releaseToUse.SelectedPackages
        Version             =   $(if($releaseToUse.Version -like "*quick*"){$releaseToUse.Version -replace "quick","move"}else{$releaseToUse.Version + "-move"})
    }
    write-host "Creating a new release as a clone of $($releaseToUse.Version)..."
    try{
        $createResult = invoke-webrequest -usebasicparsing $octopusUrl/api/releases -headers $webHeaders -method POST -body $($newRelease | convertto-json -depth 10)
    }catch{
        throw "Error creating new release - $($_.exception.message)"
    }
    if($createResult.StatusCode -ne 201 -or $createResult.StatusDescription -ne "Created"){
        throw "The POST was successful but the status returned doesn't look correct.`nCode: $($createResult.StatusCode)`nDescription: $($createResult.StatusDescription)"
    }
    $successfulRelease = $createResult | convertfrom-json
    write-host "$($successfulRelease.Id) created successfully."
    return $successfulRelease
}

