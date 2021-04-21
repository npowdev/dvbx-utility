function GetMyModTest {
    param ()
    Write-Output 'Inside DvbxUtility'
}

# Default values
# $DVBX_CFG_SRV_REL_PATH = '..\..\devilbox'
$Script:DVBX_CFG_SERVICES = [array]@()


function DvbxGetConfigFile {
    param ()

    $cfg_fn = "dvbx-cfg"
    $cfg_paths = @(`
        ("{0}\.dvbx\{1}" -f $Script:PSScriptRoot, $cfg_fn), `
        ("{0}\.{1}" -f $Script:PSScriptRoot, $cfg_fn)`
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

function DvbxGetConfigContent {
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

