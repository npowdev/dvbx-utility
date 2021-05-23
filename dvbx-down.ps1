########################################################################
# Load Base Tool: DvbxUtiliy
########################################################################
. "$($PSScriptRoot)\DvbxUtility\DvbxUtility.ps1" $PSScriptRoot
if (!$?) { Write-Error -Message "Load of DvbxUtiliy may has failed!" -EA Stop }

########################################################################
# Script code that use DvbxUtility start here
########################################################################

