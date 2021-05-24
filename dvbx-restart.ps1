########################################################################
# Load Base Tool: DvbxUtiliy
########################################################################
. "$($PSScriptRoot)\DvbxUtility\DvbxUtility.ps1" $PSScriptRoot

########################################################################
# Script code that use DvbxUtility start here
########################################################################

# Get some paths.
Write-Output ("")
Write-Output ("Project '$(Split-Path $DVBX_WorkRoot -Leaf )' at '$($PWD)'")

# Go to the work root directory.
Push-Location -LiteralPath $DVBX_WorkRoot -EA SilentlyContinue
if (! $?) { throw [System.IO.IOException]::new("Project root path not accessible.") }
try {
    # Resolve devilbox server path.
    Write-Output ("Devilbox path: '$($DVBX.DevilboxPath)'")
    $DVBX_ServerPath = (Resolve-Path -LiteralPath ($DVBX.DevilboxPath) -EA SilentlyContinue)
    if (! $?) { throw [System.IO.IOException]::new("Server path not resolvable.") }
    Write-Output ("Go to Devilbox: '$($DVBX_ServerPath)'")

    # Test path.
    if (! (Test-Path -Path $DVBX_ServerPath -PathType Container)) { 
        throw [System.IO.IOException]::new('The resolved Devilbox path not a valid directory.') 
    }
    
    # Go to devilbox server.
    Set-Location -Path ($DVBX_ServerPath) -EA SilentlyContinue
    if (! $?) { 
        throw [System.IO.IOException]::new("Failed to go to Devilbox path '$($DVBX_ServerPath)'.") 
    }
    
    # Do docker container work: stop, remove, start.
    try {
        Write-Output ("")
        Write-Output ("Stop containers...")
        docker-compose.exe stop
        if (!$? -or ($LASTEXITCODE -ne 0)) {
            throw ("Failed to stop containers. Abort!")
        }
        Write-Output ("")
        
        Write-Output ("Remove containers...")
        docker-compose.exe rm -f
        if (!$? -or ($LASTEXITCODE -ne 0)) {
            throw ("Failed to remove containers. Abort!")
        }
        Write-Output ("")
        
        Write-Output ("Start containers...")
        docker-compose.exe "up" -d $DVBX.LoadServices
        if (!$? -or ($LASTEXITCODE -ne 0)) {
            throw ("Failed to start Devilbox. Abort!")
        }
        Write-Output ("")
    }
    # Go back to last directory.
    finally {
        # Write-Output ("Go Back to last place in: $($Dvbx_Pwd)")
        Pop-Location
    }
}
# Go back to start directory.
finally {
    Pop-Location -ErrorAction SilentlyContinue
}

Write-Output ("Done.")
Write-Output ("")
