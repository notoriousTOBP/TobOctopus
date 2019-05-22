function Get-LatestOctopusPackage{
    param(
        [parameter(mandatory)]$packageName,
        [switch]$raw
    )
    if($raw){
        $packageId = $packageName
    }else{
        $packageId = "$packageName.resources"
    }
    $packageToReturn = invoke-webrequest -usebasicparsing "$octopusUrl/api/packages?NuGetPackageId=$packageId&take=1" -headers $webHeaders | convertfrom-json
    return $packageToReturn.Items
}

