
function Get-AzDOGitItemContent {
    <#
        .SYNOPSIS
            Gets the content of a file from the Azure DevOps repository.
        .PARAMETER Branch
            Name of the branch that contains the file.
        .PARAMETER Path
            Path to the file in the repository.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .PARAMETER Project
            Name of the Azure DevOps project.
        .PARAMETER OrganizationUri
            Uri of the Azure DevOps organization.
        .PARAMETER Repository
            Name of the Azure DevOps repository.
        .OUTPUTS
            Contents of the file.
    #>

    [OutputType('string')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Branch,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PATToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Project,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('https:\/\/(?:dev\.azure\.com\/[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])|(?:[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])\.visualstudio.com')]
        [string]
        $OrganizationUri,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Repository
    )

    try {
        # Adjust the parameter values.
        $Branch = Format-Branch $Branch
        $OrganizationUri = Format-OrganizationUri $OrganizationUri
        $Path = Format-Path $Path

        # Construct the URL.
        $url = "$OrganizationUri/$Project/_apis/git/repositories/$Repository/items?path=$Path&api-version=5.1&includeContent=true&versionType=Branch&version=$Branch"

        # Execute the request.
        $response = Invoke-AzDORequest `
            -PATToken $PATToken `
            -Method 'Get' `
            -Url $url
    }
    catch {
        Write-Host $PSBoundParameters
        Write-Host $url
        Write-Host $response
        # Write-Host $_.Exception.Message

        throw
    }

    return $response
}

function Get-AzDOGitItem {
    <#
        .SYNOPSIS
            Gets the details of a file, from the Azure DevOps repository.
        .PARAMETER Branch
            Name of the branch that contains the file.
        .PARAMETER OrganizationUri
            Uri of the Azure DevOps organization.
        .PARAMETER Path
            Path to the file in the repository.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .PARAMETER Project
            Name of the Azure DevOps project.
        .PARAMETER Repository
            Name of the Azure DevOps repository.
        .OUTPUTS
            Details about the file.
    #>

    [OutputType('string')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Branch,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('https:\/\/(?:dev\.azure\.com\/[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])|(?:[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])\.visualstudio.com')]
        [string]
        $OrganizationUri,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PATToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Project,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Repository
    )

    try {
        # Adjust the parameter values.
        $Branch = Format-Branch $Branch
        $OrganizationUri = Format-OrganizationUri $OrganizationUri
        $Path = Format-Path $Path

        # Construct the URL.
        $url = "$OrganizationUri/$Project/_apis/git/repositories/$Repository/items?path=$Path&api-version=5.1&download=true&versionType=Branch&version=$Branch"

        # Execute the request.
        $response = Invoke-AzDORequest `
            -Headers @{
                'Accept' = 'application/json'
            } `
            -PATToken $PATToken `
            -Method 'Get' `
            -Url $url
    }
    catch {
        Write-Host $PSBoundParameters
        Write-Host $url
        Write-Host $response
        Write-Host $_.Exception.Message

        throw
    }

    return $response
}

function Update-AzDOGitItemContent {
    <#
        .SYNOPSIS
            Updates the content of a file, in the Azure DevOps repository.
        .PARAMETER Branch
            Name of the branch that contains the file.
        .PARAMETER Comment
            The git comment to use when updating the file contents.
        .PARAMETER Content
            The new contents of the file to update.
        .PARAMETER OrganizationUri
            Uri of the Azure DevOps organization.
        .PARAMETER Path
            Path to the file in the repository.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .PARAMETER Project
            Name of the Azure DevOps project.
        .PARAMETER Repository
            Name of the Azure DevOps repository.
        .OUTPUTS
            Result of the file update.
    #>

    [OutputType('string')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Branch,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Comment,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Content,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('https:\/\/(?:dev\.azure\.com\/[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])|(?:[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])\.visualstudio.com')]
        [string]
        $OrganizationUri,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PATToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Project,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Repository
    )

    try {
        # Adjust the parameter values.
        $Branch = Format-Branch $Branch
        $OrganizationUri = Format-OrganizationUri $OrganizationUri

        $commitID = Get-AzDOLatestGitPush `
            -Branch $Branch `
            -OrganizationUri $OrganizationUri `
            -PATToken $PATToken `
            -Project $Project `
            -Repository $Repository `
            | Select-Object -ExpandProperty 'commits' `
            | Select-Object -First 1 `
            | Select-Object -ExpandProperty 'commitId'

        $Path = $Path.Replace('\', '/')
        $url = "$OrganizationUri/$Project/_apis/git/repositories/$Repository/pushes?api-version=5.1"
        $body = @{
            'refUpdates' = @(
                @{
                    'name' = "refs/heads/$Branch";
                    'oldObjectId' = $commitID;
                }
            );
            'commits' = @(
                @{
                    'comment' = $Comment;
                    'changes' = @(
                        @{
                            'changeType' = 'edit';
                            'item' = @{
                                'path' = $Path;
                            };
                            'newContent' = @{
                                'content' = $Content;
                                'contentType' = 'rawtext';
                            }
                        }
                    );
                }
            );
        }

        $response = Invoke-AzDORequest `
            -Body $body `
            -Headers @{
                'Content-Type' = 'application/json'
            } `
            -PATToken $PATToken `
            -Method 'Post' `
            -Url $url
    }
    catch {
        Write-Host $PSBoundParameters
        Write-Host $url
        Write-Host $body
        Write-Host $response
        Write-Host $_.Exception.Message

        throw
    }

    return $response
}

function Get-AzDOGitPush {
    <#
        .SYNOPSIS
            Gets the details of the specified git push.
        .PARAMETER OrganizationUri
            Uri of the Azure DevOps organization.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .PARAMETER Project
            Name of the Azure DevOps project.
        .PARAMETER PushID
            ID of the git push to retrieve the details for.
        .PARAMETER Repository
            Name of the Azure DevOps repository.
        .OUTPUTS
            Details of the git push.
    #>

    [OutputType('string')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('https:\/\/(?:dev\.azure\.com\/[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])|(?:[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])\.visualstudio.com')]
        [string]
        $OrganizationUri,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PATToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Project,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PushID,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Repository
    )

    try {
        # Adjust the parameter values.
        $OrganizationUri = Format-OrganizationUri $OrganizationUri

        # Construct the URL.
        $url = "$OrganizationUri/$Project/_apis/git/repositories/$Repository/pushes/$($PushID)?api-version=5.1"

        # Execute the request.
        $response = Invoke-AzDORequest `
            -PATToken $PATToken `
            -Method 'Get' `
            -Url $url
    }
    catch {
        Write-Host $PSBoundParameters
        Write-Host $url
        Write-Host $response
        Write-Host $_.Exception.Message

        throw
    }

    return $response
}

function Get-AzDOLatestGitPush {
    <#
        .SYNOPSIS
            Gets the details for the latest git push in the branch.
        .PARAMETER Branch
            Name of the branch to get the latest push details for.
        .PARAMETER OrganizationUri
            Uri of the Azure DevOps organization.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .PARAMETER Project
            Name of the Azure DevOps project.
        .PARAMETER Repository
            Name of the Azure DevOps repository.
        .OUTPUTS
            Details of the latest git push.
    #>

    [OutputType('string')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Branch,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('https:\/\/(?:dev\.azure\.com\/[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])|(?:[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])\.visualstudio.com')]
        [string]
        $OrganizationUri,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PATToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Project,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Repository
    )

    try {
        # Adjust the parameter values.
        $Branch = Format-Branch $Branch
        $OrganizationUri = Format-OrganizationUri $OrganizationUri

        # Construct the URL.
        $url = "$OrganizationUri/$Project/_apis/git/repositories/$Repository/pushes?&searchCriteria.refName=refs/heads/$Branch&`$top=1&api-version=5.1"

        # List the pushes for the current branch.
        $pushID = Invoke-AzDORequest `
            -PATToken $PATToken `
            -Method 'Get' `
            -Url $url `
            | Select-Object -ExpandProperty 'value' `
            | Select-Object -First 1 `
            | Select-Object -ExpandProperty 'pushId'

        # Get the details about the push.
        $reponse = Get-AzDOGitPush `
            -OrganizationUri $OrganizationUri `
            -Project $Project `
            -Repository $Repository `
            -PATToken $PATToken `
            -PushID $pushID
    }
    catch {
        Write-Host $PSBoundParameters
        Write-Host $url
        Write-Host $response
        Write-Host $_.Exception.Message

        throw
    }

    return $reponse
}

function Get-AzDOGitPullRequest {
    <#
        .SYNOPSIS
            Gets the details of the specified git pull request.
        .PARAMETER OrganizationUri
            Uri of the Azure DevOps organization.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .PARAMETER Project
            Name of the Azure DevOps project.
        .PARAMETER PullRequestID
            ID of the git pull request to retrieve the details for.
        .OUTPUTS
            Details of the git pull request.
    #>

    [OutputType('string')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('https:\/\/(?:dev\.azure\.com\/[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])|(?:[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])\.visualstudio.com')]
        [string]
        $OrganizationUri,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PATToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Project,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PullRequestID
    )

    try {
        # Adjust the parameter values.
        $OrganizationUri = Format-OrganizationUri $OrganizationUri

        # Construct the URL.
        $url = "$OrganizationUri/$Project/_apis/git/pullrequests/$($PullRequestID)?api-version=5.1"

        # Execute the request.
        $response = Invoke-AzDORequest `
            -PATToken $PATToken `
            -Method 'Get' `
            -Url $url
    }
    catch {
        Write-Host $PSBoundParameters
        Write-Host $url
        Write-Host $response
        Write-Host $_.Exception.Message

        throw
    }

    return $response
}

Export-ModuleMember -Function *