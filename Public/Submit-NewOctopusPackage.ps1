function Submit-NewOctopusPackage{
    param(
        [parameter(mandatory)]$packagePath
    )
    $systemPath         =   "D:\Systems\Scripts"
    $octoExePath        =   "$systemPath\Octo.exe"
    $octoDownloadUrl    =   "https://download.octopusdeploy.com/octopus-tools/4.42.0/OctopusTools.4.42.0.zip"
    $octoDownloadPath   =   "$env:Temp\Octo.zip"
    if(!(test-path $octoExePath)){
        write-host "Octo.exe not found - downloading..."
        try{
            invoke-restmethod -ea stop $octoDownloadUrl -OutFile $octoDownloadPath
        }catch{
            throw "Error downloading 'Octo.exe' from web - $($_.exception.message)"
        }
        write-host "Extracting Octo.exe..."
        try{
            Expand-Archive -Path $octoDownloadPath -DestinationPath $systemPath -Force
        }catch{
            throw "Error extracting 'Octo.exe' from archive - $($_.exception.message)"
        }
        if(!(test-path $octoExePath)){
            throw "Downloaded Octo.exe but it's still missing from $systemPath"
        }
    }
    write-host "Pushing $packagePath..."
    Invoke-Expression "$octoExePath push --package $packagePath --server $octopusUrl --apiKey $($webHeaders['X-Octopus-ApiKey'])"
}

