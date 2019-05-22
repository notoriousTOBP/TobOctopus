function Get-OctopusActionTemplates{
    param(
        [string]$ActionTemplateName,
        [string]$ActionTemplateId,
        [switch]$standardise
    )
    if($ActionTemplateName -and $ActionTemplateId){
        throw "Please provide -ActionTemplateName, -ActionTemplateId or neither, not both."
    }
    try{
        $allActionTemplates = Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/ActionTemplates/all" | convertfrom-json
    }catch{
        throw "Unable to get ActionTemplate details - $($_.exception.message)"
    }
    if($ActionTemplateName){
        $selectedActionTemplate = $allActionTemplates | ? Name -eq $ActionTemplateName
        if(!$selectedActionTemplate){
            throw "No ActionTemplate matching '$ActionTemplateName' found."
        }
        if($standardise){
            return $selectedActionTemplate | Select Name,Description,ActionType,Properties,Parameters
        }else{
            return $selectedActionTemplate
        }
    }elseif($ActionTemplateId){
        $selectedActionTemplate = $allActionTemplates | ? Id -eq $ActionTemplateId
        if(!$selectedActionTemplate){
            throw "No ActionTemplate matching '$ActionTemplateId' found."
        }
        if($standardise){
            return $selectedActionTemplate | Select Name,Description,ActionType,Properties,Parameters
        }else{
            return $selectedActionTemplate
        }
    }else{        
        if($standardise){
            return $allActionTemplates | Select Name,Description,ActionType,Properties,Parameters
        }else{
            return $allActionTemplates
        }
        return $allActionTemplates
    }
}

