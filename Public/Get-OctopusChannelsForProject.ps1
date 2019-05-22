function Get-OctopusChannelsForProject{
    param(
        [parameter(mandatory)]$projectName
    )
    $channelsLink = ($projectsPage | ? Name -eq $projectName).links.Channels -replace "{.*}"
    if(!$channelsLink){
        throw "No project matching '$projectName' found."
    }
    $channels = (Invoke-WebRequest -usebasicparsing -headers $webHeaders $octopusUrl$channelsLink | convertfrom-json).items
    return ($channels | select Name,Id)
}

