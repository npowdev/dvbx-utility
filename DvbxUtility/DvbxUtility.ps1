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
# Define Tool Base Functions
########################################################################

# Default values
# $DVBX_CFG_SRV_REL_PATH = '..\..\devilbox'
$Script:DVBX_CFG_SERVICES = [array]@()


function Script:DvbxGetConfigFile {
    param ()

    $cfg_fn = "dvbx-cfg"
    $cfg_paths = @(`
        ("{0}\.dvbx\{1}" -f $PSScriptRoot, $cfg_fn), `
        ("{0}\.{1}" -f $PSScriptRoot, $cfg_fn)`
    )

    $cfg = ""
    foreach ($fn in $cfg_paths) {
        if (Test-Path -Path $fn -PathType 'Leaf') { $cfg = $fn; break }
    }

    if ($cfg.Trim() -eq '') {
        throw "Script configuration file not found."
    }
    if (! (Test-Path -Path $cfg -ErrorAction SilentlyContinue)) {
        throw "Script configuration file '$($cfg)' not found."
    }
    $cfg
}

function Script:DvbxGetConfigContent {
    param ()

    try {
        $f = DvbxGetConfigFile
    }
    catch {
        throw "No configuration file found."
    }
    try {
        $a = @(Get-Content -Path $f -EA SilentlyContinue)
        if (!$?) { throw 'Cannot find path.' }
        $s = ($a -join "`n")
    }
    catch {
        throw "Cannot read configuration file '$f'."
    }
    $s
}

########################################################################
# Load Configurations
########################################################################

$DVBX_WorkRoot

# Invoke-Expression -Command (DvbxGetConfigContent) -ErrorAction Continue
# if (!$?) { Write-Error "Loading configuration failed!"; exit 128 }
        
