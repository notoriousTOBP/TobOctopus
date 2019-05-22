function New-OctopusActionTemplate{
    param(
        [parameter(mandatory)][PSCustomObject]$TemplateBody
    )
    Write-Host "Creating step template '$($TemplateBody.Name)'..."
    try{
        $postResult = Invoke-WebRequest -usebasicparsing -headers $webHeaders -Uri "$octopusUrl/api/ActionTemplates" -Method POST -body $($templateBody | ConvertTo-Json -depth 10) | ConvertFrom-Json
    }catch{
        throw "Unable to create new step template - $($_.exception.message)"
    }
    Write-Host "Step template created as '$($postResult.Id)'."
}

