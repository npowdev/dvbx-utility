########################################################################
# Base Source Load Checks
########################################################################

#-----------------------------------------------------------------------
# Check $args[0]: Got loader script path?
#-----------------------------------------------------------------------
if ($Script:args.Count -le 0) {
    throw "Abort: Need loader script path as 1st Argumen - No arguments."
}
$Script:DVBX_WorkRoot = $Script:args[0]
if (! (Test-Path -Path $Script:DVBX_WorkRoot -PathType Container -ErrorAction SilentlyContinue)) {
    throw "Abort: Need loader script path as 1st Argumen - Path not valid/found."
}

#-----------------------------------------------------------------------
# Check: Is Docker service/deamon running?
#-----------------------------------------------------------------------
docker.exe ps 2>&1 >$null
if (!$? -or ($LASTEXITCODE -ne 0)) {
    throw ("Abort: Docker service/deamon is not running.")
}


########################################################################
# Default and Constants-Like Values
########################################################################

# Settings Filename
$Script:DVBX_C_SETTINGS_FILENAME = 'dvbx-settings.json'
$Script:DVBX_C_SETTINGS_DIRNAME = '.dvbx'

# Create default settings hashtable
$Script:DVBX_C_SETTINGS_DEFAULTS = @{
    SettingsDirName = $Script:DVBX_C_SETTINGS_DIRNAME;
    DevilboxPath    = "..\..\devilbox";
    LoadServices    = "httpd", "php", "mysql", "bind"
}

# Default values
# $DVBX_CFG_SRV_REL_PATH = '..\..\devilbox'
# $Script:DVBX_CFG_SERVICES = [array]@()


########################################################################
# Define Tool Base Functions
########################################################################

function Script:DvbxGetSettingsFile {
    param ()

    $cfg_paths = @(`
        ("{0}\{1}\{2}" -f $Script:DVBX_WorkRoot, $Script:DVBX_C_SETTINGS_DIRNAME, $Script:DVBX_C_SETTINGS_FILENAME), `
        ("{0}\.{1}" -f $Script:DVBX_WorkRoot, $Script:DVBX_C_SETTINGS_FILENAME)`
    )

    $cfg = ""
    foreach ($fn in $cfg_paths) {
        if (Test-Path -Path $fn -PathType 'Leaf' -ErrorAction SilentlyContinue) { 
            $cfg = $fn
            break 
        }
    }

    if ($cfg.Trim() -eq '') {
        throw "Script configuration file not found."
    }
    if (! (Test-Path -Path $cfg -ErrorAction SilentlyContinue)) {
        throw "Script configuration file '$($cfg)' not found."
    }
    $cfg
}

########################################################################
# Load Configurations
########################################################################

# Load settings into object
$Script:DVBX = (Get-Content -LiteralPath (DvbxGetSettingsFile) -Raw | ConvertFrom-Json -Depth 100)
if (!$?) { Write-Error "Loading settings failed!"; exit 128 }

$Script:DVBX | Format-List
$Script:DVBX | Get-Member -MemberType All -Force | Format-Table
