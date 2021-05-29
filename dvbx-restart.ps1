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
    Write-Output ("")
    Write-Output ("Stops Devilbox containers...")
    docker-compose.exe stop
    if (!$? -or ($LASTEXITCODE -ne 0)) {
        throw ("Failed to stop Devilbox containers. Abort!")
    }
    Write-Output ("")
    
    Write-Output ("Removes Devilbox containers...")
    docker-compose.exe rm -f
    if (!$? -or ($LASTEXITCODE -ne 0)) {
        throw ("Failed to remove Devilbox containers. Abort!")
    }
    Write-Output ("")
    
    Write-Output ("Starts up Devilbox containers...")
    docker-compose.exe "up" -d $DVBX.LoadServices
    if (!$? -or ($LASTEXITCODE -ne 0)) {
        throw ("Failed to start Devilbox containers. Abort!")
    }
    Write-Output ("")
}
# Go back to start directory.
finally {
    Pop-Location -EA SilentlyContinue
}

Write-Output ("Devilbox restart complete.")
Write-Output ("")
