########################################################################
# Base Checks
########################################################################

# Get own source root directory.
$Script:DVBX_INIT_SourceRoot = $PSScriptRoot

$Script:DVBX_INIT_SourceRoot

$args

#-----------------------------------------------------------------------
#region Parse $args[0]: Got valid path?

# Has args?
# if ($Script:args.Count -le 0) {
#     throw "Abort: Need loader script path as 1st Argumen - No arguments."
# }

# Check to be a valid path.
# if (! (Test-Path -Path $Script:DVBX_WorkRoot -PathType Container -EA SilentlyContinue)) {
#     throw "Abort: Need loader script path as 1st Argumen - Path not valid/found."
# }

#endregion -------------------------------------------------------------
