function Get-OctopusProjectsByDatabase{
    $databasesInOctopus = @()
    $projectsPage | ?{$_.ProjectGroupId -in @("ProjectGroups-21","ProjectGroups-121")} | %{
        $projectName = $_.name
        $dbInstance = (Invoke-WebRequest -headers $webHeaders $octopusUrl$($_.links.Variables) | convertfrom-json | %{$_.Variables | ?{$_.Name -eq "JobBoard.Database.ServerInstance" -and $_.Scope.Environment -eq "Environments-141"}}).value
        write-host "Database instance for $($projectName): $dbInstance"
        $thisProject = new-object psObject
        $thisProject | add-member projectName $projectName
        $thisProject | add-member dataBase $dbInstance
        $databasesInOctopus += $thisProject
    }
    $sortedResults = @()
    $allDatabaseInstances = $($databasesInOctopus.dataBase | ?{$_ -match "s-(eu|na)*"} | select -unique | sort)
    $allDatabaseInstances | %{
        $db = $_
        $thisSorted = new-object psObject
        $thisSorted | add-member DatabaseInstance $_
        $thisSorted | add-member Projects $(($databasesInOctopus | ?{$db -eq $_.dataBase}).projectName)
        $sortedResults += $thisSorted
    }
    return $sortedResults
}

