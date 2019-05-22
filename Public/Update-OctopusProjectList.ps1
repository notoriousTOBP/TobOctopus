function Update-OctopusProjectList{
    $global:projectsPage           =    Invoke-WebRequest -headers $webHeaders $octopusUrl/api/projects/all       | convertfrom-json
}

