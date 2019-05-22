function Get-OctopusVariableSet{
    param(
        [parameter(mandatory)]$VariableSetName
    )
    $allVariableSets    =   Invoke-WebRequest -usebasicparsing -headers $webHeaders -Uri "$octopusUrl/api/libraryvariablesets/all" | ConvertFrom-Json
    $variableSetDetails =   $allVariableSets | ? Name -eq $VariableSetName
    if(!$variableSetDetails){
        throw "No library variable set matching '$variableSetName' found."
    }
    $variableSet    =   Invoke-WebRequest -usebasicparsing -headers $webHeaders -Uri "$octopusUrl/api/variables/$($variableSetDetails.VariableSetId)" | ConvertFrom-Json
    return $variableSet
}

