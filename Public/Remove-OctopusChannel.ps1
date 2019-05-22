function Remove-OctopusChannel{
    param(
        [parameter(mandatory)]$channelId
    )
    try{
        Invoke-WebRequest -usebasicparsing "$octopusUrl/api/channels/$channelId" -method DELETE -headers $webHeaders | Out-Null
    }catch{
        throw "Unable to remove channel - $($_.exception.message)"
    }
}

