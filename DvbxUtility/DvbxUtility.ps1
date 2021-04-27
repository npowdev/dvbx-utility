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

function Script:DvbxGetSettingsFilename {
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

function Script:DvbxReparseCustomObjectsToHT {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [AllowNull()][AllowEmptyString()][AllowEmptyCollection()]
        $Object
    )

    # Is Object not null and a PSCustomObject type?
    if ( ($null -ne $Object) -and ($Object -is [System.Management.Automation.PSCustomObject]) ) {
        # Get new hashtable to parse in.
        $ht = @{}
        # Loop through properties, and parse and add each into the hashtable.
        ($Object).psobject.properties | ForEach-Object { 
            # Parse property value and sub-values if any.
            $val = DvbxReparseCustomObjectsToHT -Object $_.Value
            # Set parsed value into new hashtable.
            $ht[$_.Name] = $val
        }
        # Pass back the new hashtable.
        return $ht
    }
    # ... or is Object not null and an Array type?
    elseif ( ($null -ne $Object) -and ($Object -is [array]) ) {
        # Get new array to parse in.
        $ar = @()
        # Is the Object value not an empty array, and ...
        # do we have anything to work on?
        if ($Object.Count -gt 0 ) {
            # Loop through items, and parse and add each into the array.
            @($Object) | ForEach-Object {
                # Parse value and sub-values if any.
                $val = DvbxReparseCustomObjectsToHT -Object $_
                # Set parsed value into new array.
                $ar += $val
            }
        }
        # Pass back the new array, and guarantee that ...
        # ... it's an array even if empty or one value array.
        return , $ar
    }
    # ... or else do nothing and pass back Object unmodified.
    else {
        return $Object
    }
}

function Script:DvbxLoadJsonFile {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -LiteralPath $_ -ErrorAction SilentlyContinue })]
        [string]$File
    )
    
    # Read json file
    $json = Get-Content -LiteralPath ($File) -Raw -EA SilentlyContinue
    if (!$?) { throw ([System.Management.Automation.ErrorRecord]$Error[0]).Exception }

    # Convert from json to object
    $pscobj = (ConvertFrom-Json $json -Depth 100 -EA SilentlyContinue )
    if (!$?) { throw ([System.Management.Automation.ErrorRecord]$Error[0]).Exception }
    
    # Reparse hierarhy structure of custom objects to enumerable hashtables
    $ht = @{}
    $ht = DvbxReparseCustomObjectsToHT -Object $pscobj
    if (!$?) { throw [System.FormatException]::new("Reparse object data failed.") }
    
    # Return hierarhy structure
    return $ht
}

########################################################################
# Load Configurations
########################################################################

# Load settings into object
$Script:DVBX = DvbxLoadJsonFile -File (DvbxGetSettingsFilename)
if (!$?) { Write-Error "Loading settings failed!"; exit 128 }

$Script:DVBX | Format-List
# $Script:DVBX | Get-Member -MemberType All -Force | Format-Table
