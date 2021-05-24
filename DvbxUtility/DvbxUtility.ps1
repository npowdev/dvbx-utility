########################################################################
# Base Source Load Checks
########################################################################

#-----------------------------------------------------------------------
#region Check $args[0]: Got loader script path and set in DVBX_WorkRoot?

# Has args?
if ($Script:args.Count -le 0) {
    throw "Abort: Need loader script path as 1st Argumen - No arguments."
}
# Set root work directory.
Set-Variable DVBX_WorkRoot ($Script:args[0]) -Scope Script -Option ReadOnly -Force
# Check to be a container path.
if (! (Test-Path -Path $Script:DVBX_WorkRoot -PathType Container -EA SilentlyContinue)) {
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

# Constant value of settings filename.
Set-Variable DVBX_C_SETTINGS_FILENAME ('dvbx-settings.json') -Scope Script -Option ReadOnly -Force
# Constant value of Settings directory name.
Set-Variable DVBX_C_SETTINGS_DIRNAME ('.dvbx') -Scope Script -Option ReadOnly -Force

########################################################################
# Define Tool Base Functions
########################################################################

function DvbxGetSettingsFilePathnames {
    [OutputType([System.String[]])]
    param ()
    
    return [string[]]@(
        ("{0}\{1}\{2}" -f $Script:DVBX_WorkRoot, 
            $Script:DVBX_C_SETTINGS_DIRNAME, 
            $Script:DVBX_C_SETTINGS_FILENAME)
        ("{0}\.{1}" -f $Script:DVBX_WorkRoot, 
            $Script:DVBX_C_SETTINGS_FILENAME)
    )
}

function DvbxGetCurrentSettingsFile {
    [OutputType([System.String])]
    param ()

    # Get possible pathnames of settings files in priority order.
    $filePaths = DvbxGetSettingsFilePathnames

    # Set default return value (if no settings file get found).
    $currentFile = ""

    # Loop through possible pathnames of settings files and ...
    # find the first file that exist.
    foreach ($file in $filePaths) {
        # Do $file file exist?
        if (Test-Path -Path $file -PathType 'Leaf' -EA SilentlyContinue) { 
            # Set pathname and break loop.
            $currentFile = $file
            break 
        }
    }

    # TODO: Next check needs cleanup. Check is not needed!
    # Do we found a file and is pathname Invalid?
    if (($currentFile -ne '') -and 
        (!(Test-Path -Path $currentFile -IsValid -EA SilentlyContinue)) 
    ) {
        throw "Settings file pathname '$($currentFile)' is not valid."
    }

    # Return value of settings file full pathname.
    return [string]$currentFile
}

function DvbxReparseCustomObjectsToHT {
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

function DvbxLoadJsonFile {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -LiteralPath $_ -ErrorAction SilentlyContinue })]
        [string]$File
    )
    
    # Read json file
    $jsonContent = Get-Content -LiteralPath ($File) -Raw -EA SilentlyContinue
    if (!$?) { throw ([System.Management.Automation.ErrorRecord]$Error[0]).Exception }

    # Convert from json to object
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        # Run on old PS version not supporting '-Depth' option.
        $psObject = (ConvertFrom-Json $jsonContent -EA SilentlyContinue )
    }
    else {
        # Run on PS version that support '-Depth' option.
        $psObject = (ConvertFrom-Json $jsonContent -Depth 100 -EA SilentlyContinue )
    }
    if (!$?) { throw ([System.Management.Automation.ErrorRecord]$Error[0]).Exception }
    
    # Reparse hierarhy structure of custom objects to enumerable hashtables
    $htResult = @{}
    $htResult = DvbxReparseCustomObjectsToHT -Object $psObject
    if (!$?) { throw [System.FormatException]::new("Reparse object data failed.") }
    
    # Return hierarhy structure
    return $htResult
}

function DvbxLoadDefaultSettings {
    [CmdletBinding()]
    param (
        # A Hashtable/OrderedDictionary object to be filled with settings.
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias('S')]
        # [hashtable]
        $Settings,
        # A Switch parameter to force set of existing settings.
        [Parameter(Mandatory = $false, Position = 1)]
        [switch]$Force
    )

    # Validate the Settings parameter is of type Hashtable/OrderedDictionary.
    if ((!($Settings -is [hashtable])) -and
        (!($Settings -is [System.Collections.Specialized.OrderedDictionary]))
    ) { 
        throw 'Need a hashtable or an ordered hashtable object.' 
    }

    # Collection of the default settings values.
    $Local:htDefaults = @{
        SettingsDirName = $Script:DVBX_C_SETTINGS_DIRNAME;
        DevilboxPath    = "..\..\devilbox";
        LoadServices    = @();
    }

    # Add the default settings as needed.
    $Local:htDefaults.GetEnumerator() | ForEach-Object {
        # Is $_.Key missing or are we forced to set?
        if ( (!$Settings.Contains($_.Key)) -or $Force ) {
            # Set missed hash key value pair.
            $Settings[$_.Key] = $Local:htDefaults[$_.Key]
        }
    }
}

function DvbxLoadUserSettings {
    [CmdletBinding()]
    param (
        # A Hashtable/OrderedDictionary object to be filled with settings.
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias('S')]
        # [hashtable]
        $Settings
    )

    # Validate the $Settings parameter is of type Hashtable/OrderedDictionary.
    if ((!($Settings -is [hashtable])) -and
        (!($Settings -is [System.Collections.Specialized.OrderedDictionary]))
    ) { 
        throw 'Need a hashtable or an ordered hashtable object.' 
    }

    # Get a new empty HT to collect loaded settings
    $Local:settingsLoaded = @{}

    # Get settings file pathname.
    $Local:currentFile = DvbxGetCurrentSettingsFile
    
    # Do we got/has a pathname/file for use? 
    if ($Local:currentFile.Trim()) {
        # Load and get settings as hashtable object.
        $Local:settingsLoaded = DvbxLoadJsonFile -File ($Local:currentFile)
        if (!$?) { throw "Loading settings file failed!" }
        
        # Add/Set file seetings from HT into parameter $Settings.
        $Local:settingsLoaded.GetEnumerator() | ForEach-Object {
            # Sets the new loaded settings in the $Settings parameter over defaults.
            $Settings[$_.Key] = $Local:settingsLoaded[$_.Key]
        }
    }
}

function DvbxIntSettings {
    [CmdletBinding()]
    param (
        # A Hashtable/OrderedDictionary object to be filled with settings.
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias('S')]
        # [hashtable]
        $Settings
    )

    # Validate the Settings parameter is of type Hashtable/OrderedDictionary.
    if ((!($Settings -is [hashtable])) -and
        (!($Settings -is [System.Collections.Specialized.OrderedDictionary]))
    ) { 
        throw 'Need a hashtable or an ordered hashtable object.' 
    }

    # Clear HT to be empty and collect settings.
    $Settings.Clear()

    # Load default settings values.
    DvbxLoadDefaultSettings -Settings $Settings -Force
    
    # Load user settings values from current settings file.
    DvbxLoadUserSettings -Settings $Settings
}

########################################################################
# Load Configurations
########################################################################

# Create empty script settings object.
Set-Variable -Name DVBX -Value (@{}) -Scope Script -Option ReadOnly -Force
# Init and load script settings contents into object.
DvbxIntSettings -Settings $Script:DVBX
