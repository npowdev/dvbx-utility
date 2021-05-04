########################################################################
# Load Base Tool: DvbxUtiliy
########################################################################
. "$($PSScriptRoot)\DvbxUtility\DvbxUtility.ps1" $PSScriptRoot
if (!$?) { Write-Warning -Message "Load of DvbxUtiliy may has failed!" -WarningAction Continue }

########################################################################
# Script code that use DvbxUtility start here
########################################################################

$Script:DVBX | Format-List
# $Script:DVBX | Get-Member -MemberType All -Force | Format-Table

exit 0
