function Get-OctopusKeyLastUse{
    param(
        $userName,
        $userId,
        $keyDescription,
        $daysToGet = 60
    )
    if(!$userId){
        if(!$userName){
            $userName = read-host "Enter a username"
        }
        if($userName -notmatch "@clarence.local$"){
            $actualUsername = "$userName@clarence.local"
        }else{
            $actualUsername = $userName
        }
        $userId = ($usersPage | ?{$_.username -eq $actualUsername}).id
        if(!$userId){
            throw "No user matching $userName found on $octopusUrl"
        }
        write-host "Getting access logs for $actualUsername..."
    }else{
        write-host "Getting access logs for $userId..."
    }
    write-host -foreground yellow "Please wait - the events API endpoint is slow."
    $startDate = get-date (get-date).adddays(-$daysToGet) -f yyyy-MM-dd
    $endDate = get-date (get-date).adddays(1) -f yyyy-MM-dd
    $foundEvents = @()
    try{
        $response       =   (invoke-webrequest "$octopusUrl/api/events?user=$userId&from=$startDate&to=$endDate" -headers $webHeaders | convertfrom-json)
        $foundEvents    +=  $response.Items
    }catch{
        throw "Error querying Octopus - $($_.exception.message)"
    }
    $x = 1
    $apiLogins = $foundEvents | ? {$_.IdentityEstablishedWith -like "API key '$keyDescription'*"}
    if($apiLogins){
        $lastAccessDate = get-date $apiLogins[0].Occurred
        write-host "Found last access using key specified."
        return $lastAccessDate
    }
    while($response.links.'page.next'){
        $x += 1
        write-host -foreground cyan "Getting page $x of results..."
        $response       =   (invoke-webrequest $octopusUrl$($response.links.'page.next') -headers $webHeaders | convertfrom-json)
        $foundEvents    +=  $response.Items
        $apiLogins = $foundEvents | ? {$_.IdentityEstablishedWith -like "API key '$keyDescription'*"}
        if($apiLogins){
            $lastAccessDate = get-date $apiLogins[0].Occurred
            write-host "Found last access using key specified."
            return $lastAccessDate
        }
        if((get-date $foundEvents[-1].Occurred) -lt $startDate){
            write-host -foreground yellow "No key access found in the last $daysToGet days."
            return
        }
    }
    write-host -foreground yellow "No key access found in the last $daysToGet days."
    return
}

