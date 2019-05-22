function Get-OctopusLifecycles{
    param(
        [string]$lifecycleName,
        [string]$lifecycleId
    )
    if($lifecycleName -and $lifecycleId){
        throw "Please provide -lifecycleName, -lifecycleId or neither, not both."
    }
    try{
        $allLifecycles = Invoke-WebRequest -usebasicparsing -headers $webHeaders "$octopusUrl/api/lifecycles/all" | convertfrom-json
    }catch{
        throw "Unable to get lifecycle details - $($_.exception.message)"
    }
    if($lifecycleName){
        $selectedLifecycle = $allLifecycles | ? Name -eq $lifecycleName
        if(!$selectedLifecycle){
            throw "No lifecycle matching '$lifecycleName' found."
        }
        return $selectedLifecycle
    }elseif($lifecycleId){
        $selectedLifecycle = $allLifecycles | ? Id -eq $lifecycleId
        if(!$selectedLifecycle){
            throw "No lifecycle matching '$lifecycleId' found."
        }
        return $selectedLifecycle
    }else{
        return $allLifecycles
    }
}

