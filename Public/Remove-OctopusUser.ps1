function Remove-OctopusUser{
    param(
        [parameter(mandatory)][string]$userName
    )
    if($username -notmatch "@clarence\.local$"){
        $userName = "$userName@clarence.local"
    }
    $userId = ($usersPage | ? UserName -eq $userName).Id
    if(!$userId){
        throw "No user found matching '$userName'"
    }
    try{
        Invoke-WebRequest -usebasicparsing -ea stop -method DELETE -headers $webHeaders "$octopusUrl/api/users/$userId" | out-null
    }catch{
        throw "Error removing user - $($_.exception.message)"
    }
    write-host "Successfully removed '$userName'."
    return
}

