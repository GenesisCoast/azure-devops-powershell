function Get-AzDOCurrentWorkIteration {
    <#
        .SYNOPSIS
            Gets the current work iteration.
        .PARAMETER OrganizationUri
            Uri of the Azure DevOps organization.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .PARAMETER Project
            Name of the Azure DevOps project.
        .PARAMETER Team
            Name of the Azure DevOps team to get the iteration for.
        .OUTPUTS
            Details about the current work iteration.
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
        $Team
    )

    try {
        # Adjust the parameter values.
        $OrganizationUri = Format-OrganizationUri $OrganizationUri

        # Construct the URL.
        $url = "$OrganizationUri/$Project/$Team/_apis/work/teamsettings/iterations?`$timeframe=current&api-version=5.1"

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

function Get-AzDOCurrentSprint {
    <#
        .SYNOPSIS
            Gets the details of the current sprint.
        .PARAMETER OrganizationUri
            Uri of the Azure DevOps organization.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .PARAMETER Project
            Name of the Azure DevOps project.
        .PARAMETER Team
            ID of the Team to get the sprint for.
        .OUTPUTS
            Details of the git pull request.
    #>

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
        $Team
    )

    try {
        $OrganizationUri = Format-OrganizationUri $OrganizationUri
        $url = "$OrganizationUri/$Project/$Team/_apis/work/teamsettings/iterations?`$timeframe=current&api-version=5.1"

        $response = Invoke-RestMethod `
            -Headers @{
                'Authorization' = ConvertTo-AzDOAuthorizationHeader $PATToken
            } `
            -Method Get `
            -Uri $url

        return $response
    }
    catch {
        Write-Host $PSBoundParameters
        Write-Host $url
        Write-Host $response
        Write-Host $_.Exception.Message

        throw
    }
}

Export-ModuleMember -Function *