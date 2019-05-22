function Watch-TaskProgress{
    param(
        [parameter(mandatory)][string]$taskId,
        [parameter(mandatory)][int]$waitBetweenChecks
    )
    while($state -ne "Success"){
        if($state -eq "Failed"){
            return $false
        }
        start-sleep -s $waitBetweenChecks
        $progress = (Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/tasks/$taskId" | convertfrom-json)
        $state = $progress.state
        write-host -foreground darkCyan "`nCurrent task state is: $state"
    }
    return $true
}

