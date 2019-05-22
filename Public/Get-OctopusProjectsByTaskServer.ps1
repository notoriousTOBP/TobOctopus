function Get-OctopusProjectsByTaskServer{
    $projectsInOctopus = @()
    # I put this part which pulls the deployment process and gets the task server allocated into a function to make this a bit easier to read
    function getDetails($project){
        write-host "`nGetting task server for $($project.Name)"
        $taskTarget = (((Invoke-WebRequest -headers $webHeaders $octopusUrl/api/deploymentprocesses/$($project.DeploymentProcessId)).content | convertfrom-json).steps | ? Name -eq "deploy ScheduledTasks").properties.'Octopus.Action.TargetRoles'
        $taskLetter = $taskTarget[$taskTarget.indexof("Server-P")+8] # The TargetRoles property that we've saved into $taskTarget is a comma separated string, I've manipulated the string here to get the task server letter from the end. Fragile technique
        $taskNumber = switch($taskLetter){ # Converts the task node letter into a number
            A{1}B{2}C{3}D{4}E{5}F{6}G{7}H{8}I{9}J{10}K{11}L{12}M{13}N{14}O{15}P{16}Q{17}R{18}S{19}T{20}U{21}V{22}W{23}X{24}Y{25}Z{26}
        }
        $taskServer = "eu-task$taskNumber"
        write-host "Task server for $($project.Name): $taskServer"
        $projectResult = New-Object PSObject
        $projectResult | add-member -type NoteProperty "Name" $project.Name
        $projectResult | add-member -type NoteProperty "TaskServer" $taskServer
        return $projectResult
    }

    # When listing projects from the Octopus API it splits them into 'pages' as there are so many of them. If there is another page the response contains a ".Links.'Page.Next'" property.
    # I've used that property to let me loop through until it runs out of pages, using the getDetails function to pull the project name and task server for each project on each page
    $projectsPage = (Invoke-WebRequest -headers $webHeaders $octopusUrl/api/projects).content | convertfrom-json
    $projectsPage.items | ?{$_.ProjectGroupId -in @("ProjectGroups-21","ProjectGroups-121")} | %{
        $projectsInOctopus += getDetails $_
    }
    while($projectsPage.Links.'Page.Next'){
        $projectsPage = (Invoke-WebRequest -headers $webHeaders $octopusUrl$($projectsPage.Links.'Page.Next')).content | convertfrom-json
        $projectsPage.items | ?{$_.ProjectGroupId -in @("ProjectGroups-21","ProjectGroups-121")} | %{
            $projectsInOctopus += getDetails $_
        }
    }

    # The projectsInOctopus object we've created is formatted in the opposite way to the object we get from the getInstalledTasks function
    # As in there's an entry for each project and then which server it's on, rather than an entry for each server and a list of the installed projects
    # We need the two objects to be comparable, so this bit creates a new object formatted in the required way
    $sortedResults = @()
    $projectsInOctopus.TaskServer | select -unique | sort | %{
        $server = new-object psobject
        $server | add-member noteproperty "TaskServer" $_
        $server | add-member noteproperty "Projects" @()
        $sortedResults += $server
    }
    $projectsInOctopus | %{
        ($sortedResults | ? TaskServer -eq $_.TaskServer).projects += $_.Name
    }
    return $sortedResults
}

