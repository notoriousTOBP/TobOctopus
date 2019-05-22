function Get-OctopusProjectsByStackLetter{
    $projectsInOctopus = @()
    function getDetails($project){
        $targetRoles = (((Invoke-WebRequest -headers $webHeaders $octopusUrl/api/deploymentprocesses/$($project.DeploymentProcessId)).content | convertfrom-json).steps | ? Name -eq "deploy sites").properties.'Octopus.Action.TargetRoles'
        $targetRoles = ($targetRoles -split ',' | ?{$_ -like "JobBoard-Project-Web-Stack-*"}) -replace "JobBoard-Project-Web-Stack-"
        $thisProject = @()
        $targetRoles | %{
            $thisProject += [PSCustomObject]@{
                ProjectName = $project.Name
                StackLetter = $_.toUpper()
            }
        }
        return $thisProject
    }
    $projectsPage | ?{$_.ProjectGroupId -in @("ProjectGroups-21","ProjectGroups-121")} | %{
        $projectsInOctopus += getDetails $_
    }
    $sortedResults = @()
    $allStacks = $($projectsInOctopus.stackLetter | select -unique | sort)
    $allStacks | %{
        $stack = $_
        $thisSorted = new-object psObject
        $thisSorted | add-member StackLetter $_
        $thisSorted | add-member Projects $(($projectsInOctopus | ?{$stack -eq $_.StackLetter}).projectName)
        $sortedResults += $thisSorted
    }
    return $sortedResults
}

