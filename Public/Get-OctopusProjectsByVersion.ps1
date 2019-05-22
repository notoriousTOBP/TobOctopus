function Get-OctopusProjectsByVersion{
    $results = @()
    $productionProjectGroups = @(
        "ProjectGroups-122" #JobBoard Platform testing sites
        "ProjectGroups-121" #JobBoard Platform canaries
        "ProjectGroups-21"  #JobBoard Sites
    )
    $projectIds = $projectsPage | ?{$_.ProjectGroupId -in $productionProjectGroups}
    foreach($project in $projectIds){
        $projectId = $project.id
        #write-host "Checking $($project.name)"
        foreach($deployment in (invoke-webrequest "$octopusUrl/api/deployments/?projects=$projectId&environments=Environments-141" -headers $webheaders | convertfrom-json).items){
            $thisDeployment = invoke-webrequest "$octopusUrl/api/tasks/$($deployment.taskId)" -headers $webheaders | convertfrom-json | select Description,State
            if($thisDeployment.Description -like "*quick*"){
                #write-host "$($thisDeployment.Description) is a quick deploy, ignoring."
            }elseif($thisDeployment.State -ne "Success"){
                #write-host "$($thisDeployment.Description) didn't complete successfully, ignoring."
            }else{
                #write-host "$($deployment.ReleaseId) was deployed successfully."
                $version = ($thisDeployment.Description -split "-" -split " ")[3]
                #write-host -nonewline "Most recently deployed version of "
                #write-host -foreground yellow -nonewline "$($project.Name)"
                #write-host -nonewline " is "
                #write-host -foreground green $version
                $projectVersions = new-object psObject -property @{
                    ProjectName         =   $project.Name
                    ProductionVersion   =   [system.version]$version
                    SortableVersion     =   $(($version -split "\." | %{if($_.length -eq 1){"00$_"}elseif($_.length -eq 2){"0$_"}else{$_}}) -join ".")
                }
                $results += $projectVersions
                break
            }
        }
    }
    return $results
}

