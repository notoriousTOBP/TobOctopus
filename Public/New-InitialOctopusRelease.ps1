function New-InitialOctopusRelease{
    param(
        [parameter(mandatory)]$projectName
    )
    $projectToUse = $projectsPage | ?{$_.Name -eq $projectName}
    if(!$projectToUse){
        throw "No project named '$projectName' found."
    }
    $newRelease = new-object psObject -property @{
        ProjectId           =   $projectToUse.Id
        Version             =   "1.0.0"
    }
    write-host "Creating a new release of $($projectName)..."
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

