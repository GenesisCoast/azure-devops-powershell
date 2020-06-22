function Format-Branch {
    <#
        .SYNOPSIS
            Corrects any formatting issues of the branch name.
        .PARAMETER Branch
            Name of the branch to format.
        .OUTPUTS
            The correctly formatted branch name.
    #>

    [OutputType('string')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Branch
    )

    $Branch = $Branch.Replace('refs/heads', '')
    $Branch = $Branch.TrimStart('/')

    return $Branch
}

function Format-Path {
    <#
        .SYNOPSIS
            Corrects any formatting issues of the Git item path.
        .PARAMETER Path
            Path to format.
        .OUTPUTS
            The correctly formatted path.
    #>

    [OutputType('string')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )

    $Path = $Path.Replace('\', '/')

    return $Path
}

function Format-OrganizationUri {
    <#
        .SYNOPSIS
            Corrects any formatting issues of the Azure DevOps organization uri.
        .PARAMETER OrganizationUri
            Uri of the organization to format.
        .OUTPUTS
            The correctly formatted organization uri.
    #>

    [OutputType('string')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $OrganizationUri
    )

    $OrganizationUri = $OrganizationUri.TrimEnd('/')

    return $OrganizationUri
}

function Invoke-AzDORequest {
    <#
        .SYNOPSIS
            Common function to execute an Azure DevOps API request.
        .PARAMETER Body
            Optional parameter to sepcify a body for the request.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .PARAMETER Method
            Method to use for the request.
        .PARAMETER Url
            Azure DevOps API URL to use for the request.
        .OUTPUTS
            The response from the request.
    #>

    [OutputType('psobject')]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [hashtable]
        $Body,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [hashtable]
        $Headers = @{},

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PATToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Method,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Url
    )

    # Add the authentication to the headers.
    $Headers.Add('Authorization', (ConvertTo-AzDOAuthorizationHeader $PATToken))

    # Execute the request.
    $response = Invoke-RestMethod `
        -Body ($Body  | ConvertTo-Json -Depth 10) `
        -FollowRelLink `
        -Headers $Headers `
        -MaximumFollowRelLink 2 `
        -Method $Method `
        -Uri $Url

    # Return the response.
    return $response
}

function ConvertTo-AzDOAuthorizationHeader {
    <#
        .SYNOPSIS
            Converts the PAT Token to an authorization header.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .OUTPUTS
            The authorization header for a web request.
    #>

    [OutputType('string')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PATToken
    )

    $base64Authentication = [Convert]::ToBase64String(
        [Text.Encoding]::ASCII.GetBytes(
            ":$PATToken"
        )
    )
    $authorization = "Basic $base64Authentication"

    return $authorization
}

Export-ModuleMember -Function *