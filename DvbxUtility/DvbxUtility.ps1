########################################################################
# Base Source Load Checks
########################################################################

#-----------------------------------------------------------------------
#region Check $args[0]: Got loader script path?

if ($Script:args.Count -le 0) {
    throw "Abort: Need loader script path as 1st Argumen - No arguments."
}
$Script:DVBX_WorkRoot = $Script:args[0]
if (! (Test-Path -Path $Script:DVBX_WorkRoot -PathType Container -ErrorAction SilentlyContinue)) {
    throw "Abort: Need loader script path as 1st Argumen - Path not valid/found."
}

#endregion -------------------------------------------------------------

#-----------------------------------------------------------------------
#region Check: Is Docker service/deamon running?

docker.exe ps 2>&1 >$null
if (!$? -or ($LASTEXITCODE -ne 0)) {
    throw ("Abort: Docker service/deamon is not running.")
}
#endregion -------------------------------------------------------------

########################################################################
# Default and Constants-Like Values
########################################################################

# Settings Filename
$Script:DVBX_C_SETTINGS_FILENAME = 'dvbx-settings.json'
$Script:DVBX_C_SETTINGS_DIRNAME = '.dvbx'

########################################################################
# Define Tool Base Functions
########################################################################

function Script:DvbxDefaultSettingsFilename {
    [OutputType([System.String])]
    param ()
    
    return [string]("{0}\{1}\{2}" -f $Script:DVBX_WorkRoot, 
        $Script:DVBX_C_SETTINGS_DIRNAME, 
        $Script:DVBX_C_SETTINGS_FILENAME
    )
}

function Script:DvbxGetSettingsFilename {
    param ()

    # Set possible pathnames of settings files in priority order.
    $settings_file_paths = @(
        (DvbxDefaultSettingsFilename), 
        ("{0}\.{1}" -f $Script:DVBX_WorkRoot, $Script:DVBX_C_SETTINGS_FILENAME)
    )

    # Set default return value (if no settings file get found).
    $settings_file = ""

    # Loop through possible pathnames of settings files and ...
    # find the first file that exist.
    foreach ($file in $settings_file_paths) {
        # Do $file file exist?
        if (Test-Path -Path $file -PathType 'Leaf' -EA SilentlyContinue) { 
            # Set pathname and break loop.
            $settings_file = $file
            break 
        }
    }

    # Do we found a file and is pathname Invalid?
    if (($settings_file.Trim() -ne '') -and 
        (!(Test-Path -Path $settings_file -IsValid -EA SilentlyContinue)) 
    ) {
        throw "Settings file pathname '$($settings_file)' is not valid."
    }

    # Return value of settings file full pathname.
    return [string]$settings_file
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

function Script:DvbxLoadSettings {
    param ()

    # Default settings values.
    $Local:settings_defaults = @{
        SettingsDirectory = $Script:DVBX_C_SETTINGS_DIRNAME;
        DevilboxPath      = "..\..\devilbox";
        LoadServices      = "httpd", "php", "mysql", "bind";
    }
    
    # Get a new empty HT to collect settings
    $settings = @{}

    # Get settings file pathname.
    $dvbx_fn = DvbxGetSettingsFilename
    # Do we got pathname/file for use? 
    if ($dvbx_fn.Trim()) {
        # Load settings into object (as hashtable).
        $settings = DvbxLoadJsonFile -File ($dvbx_fn)
        if (!$?) { throw "Loading settings file failed!" }
    }
    
    # Add default seetings to HT for missing default settings.
    $Local:settings_defaults.GetEnumerator() | ForEach-Object {
        # Is $_.Key missing?
        if (!$settings.ContainsKey($_.Key)) {
            # Set missed hash key value pair.
            $settings[$_.Key] = $Local:settings_defaults[$_.Key]
        }
    }
    
    # Pass back result
    return $settings
}

$Script:DVBX = DvbxLoadSettings

$Script:DVBX | Format-List
# $Script:DVBX | Get-Member -MemberType All -Force | Format-Table
