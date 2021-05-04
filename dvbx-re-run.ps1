########################################################################
# Load Base Tool: DvbxUtiliy
########################################################################
. "$($PSScriptRoot)\DvbxUtility\DvbxUtility.ps1" $PSScriptRoot
if (!$?) { Write-Error -Message "Load of DvbxUtiliy may has failed!" -EA Stop }

########################################################################
# Script code that use DvbxUtility start here
########################################################################

# Get some paths.
Write-Output ("")
Write-Output ("Current path is: $($PWD)")
Write-Output ("Project path is: $($DVBX_WorkRoot)")

$DVBX
Write-Output ("")

# Go to the work root directory.
Push-Location -LiteralPath $DVBX_WorkRoot -EA SilentlyContinue
if (! $?) { throw [System.IO.IOException]::new("Work root path not accessible.") }
try {
    # Resolve devilbox server path.
    Write-Output ("Devilbox path is set as: $($DVBX.DevilboxPath)")
    $Dvbx_Server_Path = (Resolve-Path -LiteralPath ($DVBX.DevilboxPath) -EA SilentlyContinue)
    if (! $?) { throw [System.IO.IOException]::new("Server path error.") }
    if (! (Test-Path -Path $Dvbx_Server_Path)) { 
        throw [System.IO.IOException]::new('Server path not found.') 
    }
    Write-Output ("Devilbox path resolve to: $(Resolve-Path -LiteralPath ($Dvbx_Server_Path))")
    
    # Go to devilbox server.
    Write-Output ("Go inside Devilbox in: $($Dvbx_Server_Path)")
    Push-Location -Path ($Dvbx_Server_Path) -ErrorAction SilentlyContinue
    if (! $?) { 
        throw [System.IO.IOException]::new("Failed to go to server path '$($Dvbx_Server_Path)'.") 
    }
    
    # Do docker container work: stop, remove, start.
    try {
        Write-Output ("")
        Write-Output ("Stop containers:")
        docker-compose.exe stop
        if (!$? -or ($LASTEXITCODE -ne 0)) {
            throw ("Failed to stop containers. Abort!")
        }
        Write-Output ("")
        
        Write-Output ("Remove containers:")
        docker-compose.exe rm -f
        if (!$? -or ($LASTEXITCODE -ne 0)) {
            throw ("Failed to remove containers. Abort!")
        }
        Write-Output ("")
        
        Write-Output ("Start containers:")
        docker-compose.exe "up" -d $DVBX.LoadServices
        if (!$? -or ($LASTEXITCODE -ne 0)) {
            throw ("Failed to start Devilbox. Abort!")
        }
        Write-Output ("")
    }
    # Go back to last current directory.
    finally {
        # Write-Output ("Go Back to last place in: $($Dvbx_Pwd)")
        Pop-Location
    }
}
# Go to directory back as like started.
finally {
    Pop-Location -ErrorAction SilentlyContinue
}

Write-Output ("Ready.")
