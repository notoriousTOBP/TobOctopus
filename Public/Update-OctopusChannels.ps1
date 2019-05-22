function Update-OctopusChannels{
    param(
        [parameter(mandatory)]$projectName
    )
    $channelTemplatePath = "$env:temp\ClonedRepos\microservices\delivery\octopus\channels.json"
    try{
        Update-OctopusProjectList
    }catch{
        throw "Error updating project list - $($_.exception.message)"
    }
    $octopusProject = ($projectsPage | ? Name -eq $projectName)
    if(!$octopusProject){
        throw "No project matching '$projectName' found."
    }
    try{
        [array]$currentChannels = Get-OctopusChannelsForProject $projectName
    }catch{
        throw "Error getting current channels - $($_.exception.message)"
    }
    try{
        $channelConfigs = Get-Content $channelTemplatePath | ConvertFrom-Json
    }catch{
        throw "Error importing config template - $($_.exception.message)"
    }
    try{
        $uatLifecycleId = (Get-OctopusLifecycles -lifecycleName 'Microservices - Testing').Id
    }catch{
        throw "Error getting UAT lifecycle ID - $($_.exception.message)"
    }
    ($channelConfigs | ? Name -eq "UAT").LifecycleId = $uatLifecycleId
    $channelConfigs | %{
        $_.ProjectId = $octopusProject.Id
        $channelName = $_.Name
        if($channelName -in $currentChannels.Name){
            Write-Host "Updating $channelName..."
            $channelId = ($currentChannels | ? Name -eq $channelName)[0].Id
            try{
                Invoke-WebRequest -usebasicparsing "$octopusUrl/api/channels/$channelId" -method PUT -headers $webHeaders -Body ($_ | ConvertTo-Json -depth 10) | Out-Null
                Write-Host -Foreground green "Success."
            }catch{
                throw "Error updating channel $channelId ($channelName) - $($_.exception.message)"
            }
        }else{
            Write-Host "Creating $channelName..."
            try{
                Invoke-WebRequest -usebasicparsing "$octopusUrl/api/channels" -method POST -headers $webHeaders -Body ($_ | ConvertTo-Json -depth 10) | Out-Null
                Write-Host -Foreground green "Success."
            }catch{
                throw "Error creating channel $channelId ($channelName) - $($_.exception.message)"
            }
        }
    }
    $currentChannels | ?{$_.Name -notin $channelConfigs.Name} | %{
        Write-Host "Removing $($_.Name)..."
        try{
            Remove-OctopusChannel $_.Id
            Write-Host -Foreground green "Success."
        }catch{
            throw "Error removing channel - $($_.exception.message)"
        }
    }
}

