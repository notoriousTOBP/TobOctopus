function Get-OctopusApiKeyAudit{
    $userDetails = @()
    $usersPage | %{
        $thisUser = new-object PSObject
        $thisUser | add-member userId $_.Id
        $thisUser | add-member Name $_.DisplayName
        $thisUser | add-member UserName $_.UserName
        $userDetails += $thisUser
    }
    $userDetails | %{
        write-host -foreground cyan "Checking '$($_.name)' with ID '$($_.userId)'"
        $thisId     =   $_.userId
        $userName   =   $_.userName
        $keyCheck   =   (invoke-webrequest $octopusUrl/api/users/$($thisId)/apikeys -headers $webHeaders | convertfrom-json).items
        if($keyCheck){
            $userDetails | ?{$_.userId -eq $thisId} | add-member "Keys" @()
            $keyCheck | %{
                $thisKey = $_
                ($userDetails | ?{$_.userId -eq $thisId}).Keys += @{
                    Purpose = $thisKey.purpose
                    Created = $(get-date -f g $thisKey.created)
                }
            }
            $perms = get-OctopusUserPermissions -userId $thisId
            $userDetails | ?{$_.userId -eq $thisId} | add-member Teams $perms.teams
            $userDetails | ?{$_.userId -eq $thisId} | add-member Roles $perms.roles
            $userDetails | ?{$_.userId -eq $thisId} | add-member Permissions $perms.permissions
            $userDetails | ?{$_.userId -eq $thisId} | add-member ExplicitPermissions $perms.ExplicitPermissions
        }
    }
    return $userDetails | ? Keys
}

