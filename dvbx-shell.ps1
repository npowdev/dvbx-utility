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

    # Call Devilbox shell.
    Write-Output ("")
    Write-Output ("Enters Devilbox shell...")
    cmd.exe /Q /C ".\shell.bat"
    if (!$? -or ($LASTEXITCODE -ne 0)) {
        throw ("Failed to enter Devilbox shell. Abort!")
    }
    Write-Output ("Shell leaved.")
}
# Go back to start directory.
finally {
    Pop-Location -EA SilentlyContinue
}

Write-Output ("Back again.")
Write-Output ("")
