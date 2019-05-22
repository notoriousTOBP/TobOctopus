function New-OctopusReleaseCreate{
    param(
        [parameter(mandatory)]$projectName,
        [parameter(mandatory)]$releaseVersion
    )
    $octoProject = $projectsPage | ? Name -eq $projectName
    if(!$octoProject){
        throw "No project matching '$projectName' found!"
    }
    try{
        $stepsNeedingPackages = (Get-DeploymentProcess $projectName).Steps | ?{$_.Actions.Properties.'Octopus.Action.Package.PackageId'}
    }catch{
        throw "Error getting deployment process details - $($_.exception.message)"
    }
    try{
        $masterChannelId = (Get-OctopusChannelsForProject $projectName | ? Name -eq "Master").Id
    }catch{
        throw "Error getting ID for master channel - $($_.exception.message)"
    }
    if(!$masterChannelId){
        throw "No channel ID found for master."
    }
    $packageSelection = @()
    foreach($step in $stepsNeedingPackages){
        foreach($action in ($step.Actions | ?{$_.Properties.'Octopus.Action.Package.PackageId'})){
            $packageSelection += [PSCustomObject]@{
                StepName    =   $step.Name
                ActionName  =   $action.Name
                Version     =   $releaseVersion
            }
        }
    }
    $newRelease = new-object psObject -property @{
        ProjectId           =   $octoProject.Id
        ChannelId           =   $masterChannelId
        SelectedPackages    =   $packageSelection
        Version             =   $releaseVersion
    }
    write-host "Creating a new release..."
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

