function Disable-OctopusProject {
    param(
        [parameter(mandatory)]$projectName
    )
    $targetProject = $projectsPage | Where-Object { $_.name -eq $projectName }
    if (!$targetProject) {
        throw "No project matching '$projectName' found in Octopus."
    }
    write-host "Disabling '$projectName'..."
    if ($targetProject) {
        $targetProject.IsDisabled = $true
        write-host "Sending the updated project to Octopus..."

        try {
            $putResult = invoke-webrequest -usebasicparsing $octopusUrl/api/projects/$($targetProject.Id) -headers $webHeaders -method PUT -body $($targetProject | convertto-json -depth 10)
        }
        catch {
            throw "Error updating '$projectName' project on $octopusUrl - $($_.exception.message)"   
        }
        write-host "'$projectName' disabled successfully."
    }
}

