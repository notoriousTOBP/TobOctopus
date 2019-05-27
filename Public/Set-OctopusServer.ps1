function Set-OctopusServer{
    param(
        [parameter(mandatory)][string]$HostName,
        [string][ValidateSet("http","https")]$HostProtocol = "https",
        [int]$HostPort,
        [parameter(mandatory)][string]$ApiKey
    )
    $global:webHeaders = @{
        "X-Octopus-ApiKey" = $ApiKey
    }
    try{
        $global:octopusUrl = "$($HostProtocol)://$HostName" + $(if($HostPort){":$HostPort"})
        $global:currentTargetServer    =    $hostName
        $global:serversInOctopus       =    Invoke-WebRequest -Headers $webHeaders $octopusUrl/api/machines/all -usebasicparsing      | convertfrom-json
        $global:projectsPage           =    Invoke-WebRequest -headers $webHeaders $octopusUrl/api/projects/all -usebasicparsing      | convertfrom-json
        $global:environmentsInOctopus  =    Invoke-WebRequest -Headers $webHeaders $octopusUrl/api/environments/all -usebasicparsing  | convertfrom-json
        $global:usersPage              =    Invoke-WebRequest -headers $webHeaders $octopusUrl/api/users/all -usebasicparsing         | convertfrom-json
    }catch{
        throw "Error contacting '$octopusUrl' - $($_.exception.message)"
    }
    Write-Host -foreground green "Octopus Deploy address set to $global:octopusUrl"
}