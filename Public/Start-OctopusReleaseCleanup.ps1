function Start-OctopusReleaseCleanup{
    param(
        [parameter(mandatory)][array]$projectNames,
        [parameter(mandatory)][datetime]$deletionDate,
        [switch]$force,
        [switch]$extendedEnvironments
    )
    $results = @()
    $environmentNames = @(
        "JobBoard-Qa"
        "JobBoard-UAT"
        "JobBoard-AwsStaging"
        "JobBoard-Production"
    )
    if($extendedEnvironments){
        $environmentNames = $environmentsInOctopus.name
    }
    $projectNames | %{
        $projectName = $_
        $releasesToKeep = @()
        write-host "Getting currently live releases to skip for '$projectName'..."
        $environmentNames | %{
            $environmentName = $_
            write-host "Checking '$environmentName'..."
            try{
                $successfulDeployment = Get-MostRecentSuccessfulDeployment -ea stop $projectName $environmentName
            }catch{
                $null
            }
            $releasesToKeep += $successfulDeployment.ReleaseId
            if($environmentName -eq "JobBoard-Production"){
                try{
                    $successfulDeployment = Get-MostRecentSuccessfulDeployment -ea stop $projectName $environmentName "Full"
                }catch{
                    $null
                }
                $releasesToKeep += $successfulDeployment.ReleaseId
            }
        }
        write-host "Getting a list of existing releases for '$projectName'..."
        $allReleases = Get-OctopusReleasesForProject $projectName
        $releasesToDelete = $allReleases | ?{$_.id -notin $releasesToKeep -and (get-date $_.Assembled) -lt $deletionDate}
        if($releasesToDelete){
            write-host "Found $($releasesToDelete.count) releases to delete out of $($allReleases.count) total."
            write-host "Oldest release to be deleted was created on $(get-date $releasesToDelete[-1].Assembled -f R)."
            write-host "Newest release to be deleted was created on $(get-date $releasesToDelete[0].Assembled -f R)."
            if(!$force){
                write-host "Do you want to proceed with the deletions? This cannot be undone."
                if(!(Get-UserApproval)){
                    return
                }
            }
            $releasesToDelete | sort Assembled | %{
                Remove-OctopusRelease $_.id -force
            }
        }else{
            write-host "No releases to remove for '$projectName'."
        }
        $results += [PSCustomObject]@{
            ProjectName         =   $projectName
            DeletedReleases     =   $releasesToDelete.Count
        }
    }
    return $results
}

