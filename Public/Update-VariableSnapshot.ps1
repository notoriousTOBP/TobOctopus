function Update-VariableSnapshot{
    param(
        [parameter(mandatory)]$releaseId
    )
    write-host "Updating variable snapshot for '$releaseId'..."
    try{
        Invoke-WebRequest -usebasicparsing -ea stop -method POST -headers $webHeaders "$octopusUrl/api/releases/$releaseId/snapshot-variables" | out-null
    }catch{
        throw "Error updating variable snapshot for '$releaseId' - $($_.exception.message)"
    }
    write-host -foreground cyan "Success!"
}

