function Remove-AzDOBuildFolder {
    <#
        .SYNOPSIS
            Deletes the build folder in the Azure DevOps project.
        .PARAMETER OrganizationUri
            Uri of the Azure DevOps organization.
        .PARAMETER Path
            Folder path to list the folders for.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .PARAMETER Project
            Name of the Azure DevOps project.
    #>

    [OutputType('string')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('https:\/\/(?:dev\.azure\.com\/[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])|(?:[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])\.visualstudio.com')]
        [string]
        $OrganizationUri,

        [Parameter(Mandatory = $false)]
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
        $Project
    )

    try {
        # Adjust the parameter values.
        $OrganizationUri = Format-OrganizationUri $OrganizationUri

        # Construct the URL.
        $url = "$OrganizationUri/$Project/_apis/build/folders?path=$Path&api-version=5.1-preview.2"

        # Execute the request.
        $response = Invoke-AzDORequest `
            -PATToken $PATToken `
            -Method 'Delete' `
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

function Sync-AzDOBuildFolders {
    <#
        .SYNOPSIS
            Syncs all of the folders in the Azure DevOps project.
            Will automatically delete/create folders.
        .PARAMETER FolderPaths
            List of folder paths to sync.
        .PARAMETER OrganizationUri
            Uri of the Azure DevOps organization.
        .PARAMETER Path
            Folder path to list the folders for.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .PARAMETER Project
            Name of the Azure DevOps project.
    #>

    [OutputType('string')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $FolderPaths,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('https:\/\/(?:dev\.azure\.com\/[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])|(?:[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])\.visualstudio.com')]
        [string]
        $OrganizationUri,

        [Parameter(Mandatory = $false)]
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
        $Project
    )

    try {
        # Get all teh folder paths currently in Azure DevOps.
        $existingFolderPaths = List-AzDOBuildFolders `
            -OrganizationUri $OrganizationUri `
            -Path $Path `
            -PATToken $PATToken `
            -Project $Project # `
            # | Select-Object -ExpandProperty 'value' `
            # | Select-Object -ExpandProperty 'path' `
            # | Where-Object { -not $_.EndsWith($Path) } `
            # | ForEach-Object { $_.Replace($Path, '') }

        # Compare the current and the proposed folder paths.
        $comparison = Compare-Object `
            -ReferenceObject $FolderPaths `
            -DifferenceObject $existingFolderPaths

        # Filter all of the folder paths to be deleted.
        $folderPathsToDelete = $comparison `
            | Where-Object { $_.SideIndicator -eq '=>' } `
            | Select-Object -ExpandProperty 'InputObject'

        # Iterate through and delete each of the un-required folder paths.
        foreach ($folderPath in $folderPathsToDelete) {
            Remove-AzDOBuildFolder `
                -OrganizationUri $OrganizationUri `
                -Path ($Path + $folderPath) `
                -PATToken $PATToken `
                -Project $Project
        }

        # Filter all the folder paths to be created.
        $folderPathsToCreate = $comparison `
            | Where-Object { $_.SideIndicator -eq '<=' } `
            | Select-Object -ExpandProperty 'InputObject'

        # Iterate through and create all of the new folder paths.
        foreach ($folderPath in $folderPathsToCreate) {
            New-AzDOBuildFolder `
                -OrganizationUri $OrganizationUri `
                -Path ($Path + $folderPath) `
                -PATToken $PATToken `
                -Project $Project
        }
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


function List-AzDOBuildFolders {
    <#
        .SYNOPSIS
            Lists all the build folders in the Azure DevOps project.
        .PARAMETER OrganizationUri
            Uri of the Azure DevOps organization.
        .PARAMETER Path
            Folder path to list the folders for.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .PARAMETER Project
            Name of the Azure DevOps project.
        .OUTPUTS
            List of the build folders.
    #>

    [OutputType('string')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('https:\/\/(?:dev\.azure\.com\/[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])|(?:[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])\.visualstudio.com')]
        [string]
        $OrganizationUri,

        [Parameter(Mandatory = $false)]
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
        $Project
    )

    try {
        # Adjust the parameter values.
        $OrganizationUri = Format-OrganizationUri $OrganizationUri

        # Construct the URL.
        if (-not [string]::IsNullOrWhiteSpace($Path)) {
            $url = "$OrganizationUri/$Project/_apis/build/folders/$($Path)?api-version=5.1-preview.2"
        }
        else {
            $url = "$OrganizationUri/$Project/_apis/build/folders?api-version=5.1-preview.2"
        }

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

function New-AzDOBuildFolder {
    <#
        .SYNOPSIS
           Creates a new build folder in the Azure DevOps project.
        .PARAMETER OrganizationUri
            Uri of the Azure DevOps organization.
        .PARAMETER Path
            Folder path to list the folders for.
        .PARAMETER PATToken
            PAT Token for authenticating with Azure DevOps.
        .PARAMETER Project
            Name of the Azure DevOps project.
    #>

    [OutputType('string')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('https:\/\/(?:dev\.azure\.com\/[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])|(?:[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9])\.visualstudio.com')]
        [string]
        $OrganizationUri,

        [Parameter(Mandatory = $false)]
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
        $Project
    )

    try {
        # Adjust the parameter values.
        $OrganizationUri = Format-OrganizationUri $OrganizationUri

        # Construct the URL.
        $url = "$OrganizationUri/$Project/_apis/build/folders?path=$Path&api-version=5.1-preview.2"

        # Construct the body.
        $body = @{
            'path' = $Path
        }

        # Execute the request.
        $response = Invoke-AzDORequest `
            -Body $body `
            -PATToken $PATToken `
            -Method 'Put' `
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