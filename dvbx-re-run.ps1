########################################################################
# Load Base Tool: DvbxUtiliy
########################################################################
. "$($PSScriptRoot)\DvbxUtility\DvbxUtility.ps1" $PSScriptRoot


exit 0
        
########################################################################
# Script code start here
########################################################################

# Check docker service/deamon is running.
docker.exe ps 2>&1 >$null
if (!$? -or ($LASTEXITCODE -ne 0)) {
    Write-Error ("Docker service/deamon is not running. Abort!"); exit 1
}

# Get some paths.
$Dvbx_Pwd = $PWD
$Dvbx_Project_Path = $PSScriptRoot

Write-Output ("Current path is: $($Dvbx_Pwd)")
Write-Output ("Project path is: $($Dvbx_Project_Path)")
Write-Output ("")

# Resolve devilbox server path.
$Dvbx_Server_Path = (Resolve-Path -Path (Join-Path -Path $Dvbx_Project_Path -ChildPath $DVBX_CFG_SRV_REL_PATH -ea SilentlyContinue) -EA SilentlyContinue)
if (! $?) { Write-Error ("Server path invalid."); exit 1 }
if (! (Test-Path -Path $Dvbx_Server_Path)) { Write-Error ('Server path not found.'); exit 1 }

# Go to devilbox server.
Write-Output ("Go inside Devilbox in: $($Dvbx_Server_Path)")
Push-Location -Path ($Dvbx_Server_Path) -ErrorAction SilentlyContinue
if (! $?) { Write-Error ("Failed to go to server path '$($Dvbx_Server_Path)'."); exit 1 }
Write-Output ("")

# Do docker container work: stop, remove, start.
try {
    Write-Output ("Stop containers:")
    docker-compose.exe stop
    if (!$? -or ($LASTEXITCODE -ne 0)) {
        throw ("Failed to stop containers. Abort!")
    }
    Write-Output ("")
    
    Write-Output ("Remove containers:")
    docker-compose.exe rm -f
    if (!$? -or ($LASTEXITCODE -ne 0)) {
        throw ("Failed to run docker-compose rm. Abort!")
        "Failed to remove containers. Abort!"
    }
    Write-Output ("")
    
    Write-Output ("Start containers:")
    docker-compose.exe "up" -d $DVBX_CFG_SERVICES
    if (!$? -or ($LASTEXITCODE -ne 0)) {
        throw ("Failed to start Devilbox. Abort!")
    }
    Write-Output ("")
}
# Go back to last current directory.
finally {
    Write-Output ("Go Back to last place in: $($Dvbx_Pwd)")
    Pop-Location
}
Write-Output ("Ready.")