function Update-OctopusUsersFromAd{
    $octopusUsers = @()
    write-host "Getting list of Octopus groups from AD..."
    $searchScope = switch($currentTargetServer){
        "Octopussy" {"Octopus_"}
        default {$currentTargetServer}
    }
    $octopusUserGroups = (get-adgroup -filter "Name -like '$searchScope*'").Name
    write-host "Getting members from groups..."
    $octopusUserGroups | %{
        write-host "Checking $_..."
        (Get-ADGroupMember $_).SamAccountName | %{
            $octopusUsers += "$_@clarence.local"
        }
    }
    $octopusUsers | %{
        $_ = "$_@clarence.local"
    }
    write-host "Comparing AD users to users in Octopus..."
    $usersToDelete = ($usersPage | ?{$_.IsService -eq $False -and $_.username -notin $octopusUsers}).Username
    if(!$usersToDelete){
        write-host "No users to remove."
        return
    }
    write-host "Found $($usersToDelete.count) users to remove from Octopus."
    $usersToDelete | %{
        try{
            Remove-OctopusUser -ea stop $_
        }catch{
            throw "Error removing user - $($_.exception.message)"
        }
    }
}

