function Set-OctopusServer{
    param(
        [parameter(mandatory)][ValidateSet("octopussy","thekraken","wonderpus","octopodes")][string]$hostName
    )
    switch($hostName){
        "octopussy"{
            $(
                $global:webHeaders = @{
                    "X-Octopus-ApiKey" = $(
                        if($awsAccountId -in $parameterAccessAccounts){
                            (Get-SSMParameter -Name systems-octopus-octopodes -WithDecryption $true).Value
                        }else{
                            Get-UserApiKeys $hostname
                        }
                    )
                }
                $global:octopusUrl = "https://octopodes"
            )
        }
        "octopodes"{
            $(
                $global:webHeaders = @{
                    "X-Octopus-ApiKey" = $(
                        if($awsAccountId -in $parameterAccessAccounts){
                            (Get-SSMParameter -Name "systems-octopus-$($hostname.tolower())" -WithDecryption $true).Value
                        }else{
                            Get-UserApiKeys $hostname
                        }
                    )
                }
                $global:octopusUrl = "https://octopodes"
            )
        }
        "thekraken"{
            $(
                $global:webHeaders = @{
                    "X-Octopus-ApiKey" = $(
                        if($awsAccountId -in $parameterAccessAccounts){
                            (Get-SSMParameter -Name "systems-octopus-$($hostname.tolower())" -WithDecryption $true).Value
                        }else{
                            Get-UserApiKeys $hostname
                        }
                    )
                }
                $global:octopusUrl = "https://thekraken:444"
            )
        }
        "wonderpus"{
            $(
                $global:webHeaders = @{
                    "X-Octopus-ApiKey" = $(
                        if($awsAccountId -in $parameterAccessAccounts){
                            (Get-SSMParameter -Name "systems-octopus-$($hostname.tolower())" -WithDecryption $true).Value
                        }else{
                            Get-UserApiKeys $hostname
                        }
                    )
                }
                $global:octopusUrl = "https://wonderpus"
            )
        }
    }
    $global:currentTargetServer    =    $hostName
    $global:serversInOctopus       =    Invoke-WebRequest -Headers $webHeaders $octopusUrl/api/machines/all -usebasicparsing      | convertfrom-json
    $global:projectsPage           =    Invoke-WebRequest -headers $webHeaders $octopusUrl/api/projects/all -usebasicparsing      | convertfrom-json
    $global:environmentsInOctopus  =    Invoke-WebRequest -Headers $webHeaders $octopusUrl/api/environments/all -usebasicparsing  | convertfrom-json
    $global:usersPage              =    Invoke-WebRequest -headers $webHeaders $octopusUrl/api/users/all -usebasicparsing         | convertfrom-json
    Write-Host -foreground green "Octopus Deploy address set to $global:octopusUrl"
}

