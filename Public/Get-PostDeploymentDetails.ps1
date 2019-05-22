function Get-PostDeploymentDetails{
    $deploymentId           =   $OctopusParameters['Octopus.Deployment.Id']
    $releaseVersion         =   $OctopusParameters['Octopus.Release.Number']
    $projectName            =   $OctopusParameters['Octopus.Project.Name']
    $previousReleaseVersion =   $OctopusParameters['Octopus.Release.CurrentForEnvironment.Number']
    if($OctopusParameters['Octopus.Release.Number'] -match "-quick$"){
        write-host "This is a quick deployment, skipping this step."
        return
    }
	. $PSScriptroot\..\Slack\SlackFunctions
    . $PSScriptroot\..\NewRelic\NewRelicFunctions
    write-host "Querying Octopus API for details on the 'approve deployment' step for '$deploymentId'..."
    try{
        $interruptionStatus = Invoke-WebRequest -ea stop $octopusUrl/api/interruptions?regarding=$deploymentId -Headers $webHeaders | convertfrom-json
    }catch{
        write-warning "Error accessing the Octopus API - $($_.exception.message)"
    }
    if(!$interruptionStatus){
        write-warning "I couldn't find the result of the manual intervention step for this deployment ($deploymentId)."
    }
    try{
        $quoteOfTheDay = (invoke-webrequest -ea stop http://quotes.rest/qod | convertfrom-json ).contents.quotes.quote
    }catch{
        $quoteOfTheDay = "Do not put your faith in an API, for it may go wrong."
    }
    $userEmail      =   ($usersPage | ?{$_.id -eq $interruptionStatus.items.ResponsibleUserId}).EmailAddress
    $userName       =   ($usersPage | ?{$_.id -eq $interruptionStatus.items.ResponsibleUserId}).Username
    $slackUsers     =   Get-SlackUsers
    $userSlack      =   if($userEmail){
        ($slackUsers | ?{$_.profile.email -eq $userEmail}).name
    }else{
        "Not found."
        $userEmail = "Not found."
    }
    $sqsUpdateScript = "Import-Module AWSPowershell
    `$sqsQueue       =   `"https://sqs.eu-west-1.amazonaws.com/285294353603/dbAdministrator`"
    `$messageData    =   [PSCustomObject]@{
        ProjectName    =   `"$projectName`"
        ReleaseNumber  =   `"$releaseVersion`"
        UserEmail      =   `"$userEmail`"
        UserSlack      =   `"`"
    } | convertto-json

    `$messageAttributes = @{
        UserName = [Amazon.SQS.Model.MessageAttributeValue]@{
            DataType    =   `"String`" 
            StringValue =   `"$userName`"
        }
        TaskName = [Amazon.SQS.Model.MessageAttributeValue]@{
            DataType    =   `"String`" 
            StringValue =   `"deployment-performance-check`"
        }
        AssetName = [Amazon.SQS.Model.MessageAttributeValue]@{
            DataType    =   `"String`" 
            StringValue =   `"null`"
        }
        TaskAssetId = [Amazon.SQS.Model.MessageAttributeValue]@{
            DataType    =   `"String`" 
            StringValue =   `"null`"
        }
    }
    `$messageDataTwo    =   [PSCustomObject]@{
        ProjectName    =   `"$projectName`"
    } | convertto-json

    `$messageAttributesTwo = @{
        UserName = [Amazon.SQS.Model.MessageAttributeValue]@{
            DataType    =   `"String`" 
            StringValue =   `"$userName`"
        }
        TaskName = [Amazon.SQS.Model.MessageAttributeValue]@{
            DataType    =   `"String`" 
            StringValue =   `"collect-scheduled-tasks`"
        }
        AssetName = [Amazon.SQS.Model.MessageAttributeValue]@{
            DataType    =   `"String`" 
            StringValue =   `"null`"
        }
        TaskAssetId = [Amazon.SQS.Model.MessageAttributeValue]@{
            DataType    =   `"String`" 
            StringValue =   `"null`"
        }
    }
    try{
        Send-SQSMessage -queueurl `$sqsQueue -messagebody `$messageData -MessageAttributes `$messageAttributes | out-null
    }catch{
        write-warning `"Error posting the deployment tracking data to SQS - `$(`$_.exception.message)`"
    }
    try{
        Send-SQSMessage -queueurl `$sqsQueue -messagebody `$messageDataTwo -MessageAttributes `$messageAttributesTwo | out-null
    }catch{
        write-warning `"Error posting the task update data to SQS - `$(`$_.exception.message)`"
    }"
    Invoke-AdHocScript $sqsUpdateScript mgmt-ops $true
    try{
        new-newRelicDeploymentLog -ea stop -projectName $projectName -versionNumber $releaseVersion -changeLog "Redacted" -description "'$projectName' deployed to Production by $displayName" -userEmail $userEmail
    }catch{
        write-warning "Error occured when sending deployment details to New Relic - $($_.exception.message)"
    }
}

