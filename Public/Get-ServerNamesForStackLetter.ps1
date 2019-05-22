function Get-ServerNamesForStackLetter{
    param(
        [parameter(mandatory)]$stackLetter,
        [string]$stackRegion
    )
    $stackLetter = $stackLetter.toUpper()
    if(!$stackRegion){
        $stackRegion = switch($stackLetter){
            "x" {"NA"}
            "y" {"NA"}
            "z" {"NA"}
            default {"EU"}
        }
    }
    $newStackLetter = switch($stackLetter){
        "L" {"I"}
        "M" {"I"}
        "P" {"J"}
        "O" {"K"}
        "x" {"C"}
        "y" {"B"}
        "z" {"A"}
        default {$stackLetter}
    }
    write-host "Getting target server names for Octopus stack $stackLetter..."
    $oldRoleName = "JobBoard-Project-Web-Server-P$stackLetter"
    $newRoleName = "JobBoard-Project-Web-Stack-$stackRegion-$newStackLetter"
    $serverNames = ($serversInOctopus | ?{$_.status -eq "Online" -and ($_.roles -contains $oldRoleName -or $_.roles -contains $newRoleName)}).name
    if(!$serverNames){
        throw "No online servers found assigned to stack $stackLetter."
    }
    write-host "Server names retrieved successfully."
    return $serverNames
}

