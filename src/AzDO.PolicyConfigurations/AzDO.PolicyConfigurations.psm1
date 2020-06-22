function List-AzDOPolicyConfigurations {
    <#
        .SYNOPSIS
            Lists all of the policy configurations in the Azure DevOps project.
        .PARAMETER OrganizationUri
            Uri of the Azure DevOps organization.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .PARAMETER PolicyType
            Optional policy type to filter the configurations for.
        .PARAMETER Project
            Name of the Azure DevOps project.
        .OUTPUTS
            List of policy configurations.
    #>

    [OutputType('psobject')]
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
        $Project
    )

    try {
        # Adjust the parameter values.
        $OrganizationUri = Format-OrganizationUri $OrganizationUri

        # Construct the URL.
        $url = "$OrganizationUri/$Project/_apis/policy/configurations?api-version=5.1"

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

function Remove-AzDOPolicyConfigurations {
    <#
        .SYNOPSIS
            Removes the policy configurations in the Azure DevOps project.
        .PARAMETER ConfigurationID
            ID of the configuration to delete.
        .PARAMETER OrganizationUri
            Uri of the Azure DevOps organization.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .PARAMETER Project
            Name of the Azure DevOps project.
    #>

    [OutputType('psobject')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]


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
        $Project
    )

    try {
        # Adjust the parameter values.
        $OrganizationUri = Format-OrganizationUri $OrganizationUri

        # Construct the URL.
        $url = "$OrganizationUri/$Project/_apis/policy/configurations?api-version=5.1"

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

function Create-AzDOPolicyConfigurations {
    <#
        .SYNOPSIS
            Removes the policy configurations in the Azure DevOps project.
        .PARAMETER OrganizationUri
            Uri of the Azure DevOps organization.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .PARAMETER Policy
            The policy details to add.
        .PARAMETER Project
            Name of the Azure DevOps project.
    #>

    [OutputType('psobject')]
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
        [hashtable]
        $Policy,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Project
    )

    try {
        # Adjust the parameter values.
        $OrganizationUri = Format-OrganizationUri $OrganizationUri

        # Construct the URL.
        $url = "$OrganizationUri/$Project/_apis/policy/configurations?api-version=5.1"

        # Execute the request.
        $response = Invoke-AzDORequest `
            -Body $Policy
            -PATToken $PATToken `
            -Method 'Post' `
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