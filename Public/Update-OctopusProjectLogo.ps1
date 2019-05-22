function Update-OctopusProjectLogo{
    param(
        [parameter(mandatory)]$projectName,
        $filePath,
        [switch]$force
    )
    $projectId = ($projectsPage | ? Name -eq $projectName).id
    if(!$projectId){
        throw "No project matching '$projectName' found."
    }
    $projectUrl = "$octopusUrl/api/projects/$projectId/logo"
    if(!$filePath){
        if(!$force){
            write-host "You've not provided a path to a file - continuing will delete the existing logo."
            if(!(Get-UserApproval)){
                return
            }
        }
        write-host "Removing logo for '$projectName'..."
        try{
            Invoke-WebRequest -usebasicparsing -ea stop -method POST -headers $webHeaders $projectUrl | out-null
        }catch{
            throw "Error removing image - $($_.exception.message)"
        }
        write-host "Done."
        return
    }
    if(!(test-path $filePath)){
        throw "File not found - '$filePath'"
    }
    Add-Type -AssemblyName System.Web
    Add-Type -AssemblyName System.Net.Http

    #$mimeType = [System.Web.MimeMapping]::GetMimeMapping($filePath)
    #if($mimeType){
    #    $ContentType = $mimeType
    #}else{
        $ContentType = "application/octet-stream"
    #}

	$httpClientHandler = New-Object System.Net.Http.HttpClientHandler

    $httpClient = New-Object System.Net.Http.HttpClient $httpClientHandler
    $httpClient.DefaultRequestHeaders.Add("X-Octopus-ApiKey", $($webHeaders['X-Octopus-ApiKey']))

    $packageFileStream = New-Object System.IO.FileStream @($filePath, [System.IO.FileMode]::Open)

	$contentDispositionHeaderValue = New-Object System.Net.Http.Headers.ContentDispositionHeaderValue "form-data"
	$contentDispositionHeaderValue.Name = "fileData"
	$contentDispositionHeaderValue.FileName = (Split-Path $filePath -leaf)

    $streamContent = New-Object System.Net.Http.StreamContent $packageFileStream
    $streamContent.Headers.ContentDisposition = $contentDispositionHeaderValue
    $streamContent.Headers.ContentType = New-Object System.Net.Http.Headers.MediaTypeHeaderValue $ContentType

    $content = New-Object System.Net.Http.MultipartFormDataContent
    $content.Add($streamContent)

    try{
		$response = $httpClient.PostAsync($projectUrl, $content).Result
		if (!$response.IsSuccessStatusCode){
			$responseBody = $response.Content.ReadAsStringAsync().Result
			$errorMessage = "Status code {0}. Reason {1}. Server reported the following message: {2}." -f $response.StatusCode, $response.ReasonPhrase, $responseBody
			throw [System.Net.Http.HttpRequestException] $errorMessage
		}
		return
    }catch{
        throw "Error posting message to Octopus - $($_.exception.message)"
    }
}

