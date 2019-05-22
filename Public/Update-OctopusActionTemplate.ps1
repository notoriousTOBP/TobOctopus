function Update-OctopusActionTemplate{
    param(
        [string]$ActionTemplateName,
        [string]$ActionTemplateId,
        [parameter(mandatory)][PSCustomObject]$TemplateBody,
        [switch]$UpdateUsage,
        [switch]$CreateNew
    )
    $updateTemplate = $false
    if(($ActionTemplateName -and $ActionTemplateId) -or (!$ActionTemplateName -and !$ActionTemplateId)){
        throw "Please provide either -ActionTemplateName, -ActionTemplateId, not neither or both."
    }
    if($ActionTemplateName){
        try{
            $allActionTemplates = Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/ActionTemplates/all" | ConvertFrom-Json
        }catch{
            throw "Unable to get ActionTemplate details - $($_.exception.message)"
        }
        $thisActionTemplate =   $allActionTemplates | ? Name -eq $ActionTemplateName
        $ActionTemplateId   =   $thisActionTemplate.Id
        if(!$ActionTemplateId){
            if($createNew){
                Write-Host "'$ActionTemplateName' doesn't exist."
                try{
                    New-OctopusActionTemplate -TemplateBody $TemplateBody
                }catch{
                    throw "Error creating template - $($_.exception.message)"
                }
                return
            }
            throw "No ActionTemplate matching '$ActionTemplateName' found."
        }
    }else{
        try{
            $thisActionTemplate = Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/ActionTemplates/$ActionTemplateId" | ConvertFrom-Json
        }catch{
            if($createNew){
                Write-Host "'$ActionTemplateName' doesn't exist."
                try{
                    New-OctopusActionTemplate -TemplateBody $TemplateBody
                }catch{
                    throw "Error creating template - $($_.exception.message)"
                }
                return
            }
            throw "Unable to get ActionTemplate details - $($_.exception.message)"
        }
    }
    $propertiesToCompare        =   ($TemplateBody | Get-Member | ? MemberType -eq "NoteProperty").Name | ?{$_ -notin "Properties","Parameters"}
    $actionPropertiesToCompare  =   ($TemplateBody.Properties | Get-Member | ? MemberType -eq "NoteProperty").Name
    foreach($property in $propertiesToCompare){
        if($thisActionTemplate.$property -ne $templateBody.$property){
            Write-Host "'$property' is updated."
            $updateTemplate = $true
        }
    }
    foreach($actionProperty in $actionPropertiesToCompare){
        if(($thisActionTemplate.Properties.$actionProperty -join "" -replace "\s*") -ne ($templateBody.Properties.$actionProperty -join "" -replace "\s*")){
            Write-Host "'$actionProperty' is updated."
            $updateTemplate = $true
        }
    }
    if($updateTemplate){
        Write-Host "Updating step template '$ActionTemplateId'..."
        try{
            $putResult = Invoke-WebRequest -usebasicparsing -headers $webHeaders -Uri "$octopusUrl/api/ActionTemplates/$actionTemplateId" -Method PUT -body $($templateBody | ConvertTo-Json -depth 10) | ConvertFrom-Json
        }catch{
            throw "Unable to get ActionTemplate details - $($_.exception.message)"
        }
        if($updateUsage){
            try{
                Update-OctopusActionTemplateUsage -ActionTemplateId $ActionTemplateId -ea stop
            }catch{
                throw "Error updating template usage - $($_.exception.message)"
            }
        }
    }else{
        Write-Host "No updates to perform."
    }
    Write-Host "Done."
}

