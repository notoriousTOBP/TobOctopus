function Get-OctopusProjectsByWebNode{
    param(
        [string]$projectName
    )
    $projectsInOctopus = @()
    function getDetails($project){
        $targetRoles = (((Invoke-WebRequest -headers $webHeaders $octopusUrl/api/deploymentprocesses/$($project.DeploymentProcessId)).content | convertfrom-json).steps | ? Name -eq "deploy sites").properties.'Octopus.Action.TargetRoles'
        $targetRoles = $targetRoles -split ',' | ?{$_ -like "JobBoard-Project-Web-Server-P*" -or $_ -like "JobBoard-Project-Web-Stack-*"}
        $targetNodes = $serversInOctopus | ?{$_.status -eq "Online"} | %{$name = $_.name;$_.roles | ?{$_ -like "JobBoard-Project-Web-Server-P*" -or $_ -like "JobBoard-Project-Web-Stack-*"} |?{$_ -in $targetRoles} | %{$name}}
        $targetNodes = $targetNodes | sort -unique
        write-host "Web nodes for $($project.Name): $targetNodes"
        $thisProject = new-object psObject
        $thisProject | add-member projectName $project.Name
        $thisProject | add-member webNodes $targetNodes
        return $thisProject
    }
    if($projectName){
        $projectDetails = $projectsPage | ?{$_.Name -eq $projectName}
        if(!$projectDetails){
            throw "No project matching '$projectName' found."
        }
        $projectsInOctopus += getDetails $projectDetails
    }else{
        $projectsPage | ?{$_.ProjectGroupId -in @("ProjectGroups-21","ProjectGroups-121")} | %{
            $projectsInOctopus += getDetails $_
        }
    }
    $sortedResults = @()
    $allNodes = $($projectsInOctopus.webNodes | select -unique | sort)
    $allNodes | %{
        $node = $_
        $thisSorted = new-object psObject
        $thisSorted | add-member webNode $_
        $thisSorted | add-member Projects $(($projectsInOctopus | ?{$node -in $_.webnodes}).projectName)
        $sortedResults += $thisSorted
    }
    return $sortedResults
}

