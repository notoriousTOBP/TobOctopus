function Get-OctopusUserPermissions{
    param(
        $userName,
        $userId
    )
    function test-explicitPerms{
        (($foundPerms.Permissions | gm | ? MemberType -eq "NoteProperty").name[0] | %{$name = $_;$foundPerms.Permissions.$_} | gm | ? MemberType -eq "NoteProperty").name | %{if($foundPerms.Permissions.$name.$_.count -ne 0){$result = $true}}
    }
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
        write-host "Getting permission details for $actualUsername..."
    }else{
        write-host "Getting permission details for $userId..."
    }
    $allPermissions = [PSCustomObject]@{
        UserName            =   $userName
        Teams               =   @()
        Roles               =   @()
        Permissions         =   @()
        ExplicitPermissions =   $false
    }
    try{
        $foundPerms = (invoke-webrequest $octopusUrl/api/users/$userId/permissions -headers $webHeaders | convertfrom-json)
    }catch{
        throw "Error querying Octopus - $($_.exception.message)"
    }
    write-host "Processing permissions..."
    if(test-explicitPerms){
        $allPermissions.ExplicitPermissions = $true
        write-warning "$username has directly applied permissions. This should be looked at and fixed ASAP."
    }
    $foundPerms.Teams | %{
        $allPermissions.Teams += $_.name
        $roles = (invoke-webrequest "$octopusUrl/api/teams/$($_.Id)" -headers $webHeaders | convertfrom-json).UserRoleIds
        $roles | %{
            (invoke-webrequest $octopusUrl/api/userroles/$_ -headers $webHeaders | convertfrom-json) | %{
                $allPermissions.Roles += $_.name
                $allPermissions.Permissions += $_.GrantedPermissions
            }
        }
    }
    $allPermissions.Permissions = $allPermissions.Permissions | sort -unique
    write-host -foreground green "Done."
    return $allPermissions
}

