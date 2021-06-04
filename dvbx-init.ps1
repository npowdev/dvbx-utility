########################################################################
# Base Checks
########################################################################

# Default values
$Script:DVBX_INIT_C_DVBX_DIRNAME = "DvbxUtility"
$Script:DVBX_INIT_C_FILE = (Split-Path -Path $PSCommandPath -Leaf )

$Script:DVBX_INIT_CurrentDir = $PWD
Push-Location $Script:DVBX_INIT_CurrentDir -ErrorAction Stop
try {
    # SOURCE DIRECTORY
    # ----------------
    # Get own source root directory.
    $Script:DVBX_INIT_SrcRoot = $PSScriptRoot
    # Check to be a valid path.
    if (! (Test-Path -Path $Script:DVBX_INIT_SrcRoot -PathType Container -EA SilentlyContinue)) {
        throw "Abort: Source path from script not valid/found."
    }
    
    # DESTINATION DIRECTORY
    # ---------------------
    # Default path of destination container
    $Script:DVBX_INIT_DestRoot = "."
    # Has one+ args?
    if ($Script:args.Count -ge 1) {
        # Parse $args[0]: Got path for destination?
        $p1 = $Script:args[0]
        if ($p1 -is [string]) { [string]$str = $p1 }
        else { [string]$str = $p1.toString() }
        if ([System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($str)) {
            throw "Abort: Parameter 1 path string has wildcards."
        }
        if ($str.Length -gt 0 -and $str.Trim().Length -gt 0) {
            $Script:DVBX_INIT_DestRoot = $str
        }
        else {
            throw "Abort: Parameter 1 is not valid path string."
        }
    }
    # Parse to full dest path.
    $Script:DVBX_INIT_DestRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Script:DVBX_INIT_DestRoot)

    # State output at beginning.
    Write-Output ("")
    Write-Output ("Init into: '$(Split-Path $Script:DVBX_INIT_DestRoot -Leaf )'")
    Write-Output ("      Src: '$($Script:DVBX_INIT_SrcRoot )'")
    Write-Output ("     Dest: '$($Script:DVBX_INIT_DestRoot )'")
    Write-Output ("")

    # Going into source folder to work with found files.
    Push-Location -Path $Script:DVBX_INIT_SrcRoot
    try {
        # Builds paths with predefined wildcards muster to the source files.
        $aSrcFilesPaths = , ("$($Script:DVBX_INIT_SrcRoot)\dvbx-*.ps1"),
        ("$($Script:DVBX_INIT_SrcRoot)\$($Script:DVBX_INIT_C_DVBX_DIRNAME)\*.ps1")
        
        # Set empty HT to collect full source (key) and destination (value) file paths.
        [hashtable]$aCopyFiles = @{ }
        # Resolves the relative source file names paths.
        $aSrcFilesPaths | Resolve-Path -Relative | Where-Object { 
            # Filter out me.
            $_ -notmatch ("$($Script:DVBX_INIT_C_FILE)" + '$') 
        } | ForEach-Object {
            # Strip '.\' in front of relative paths.
            $_ -ireplace '^\.\\+', '' 
        } | ForEach-Object {
            # Build and collect full source and destination filepaths.
            $aCopyFiles.($Script:DVBX_INIT_SrcRoot, $_ -join '\') = ( $Script:DVBX_INIT_DestRoot, $_ -join '\')
            # No pipeline pass through.
        } | Out-Null

        # Create dest directory tree, if needed.
        if (!(Test-Path -LiteralPath $Script:DVBX_INIT_DestRoot -PathType Container -EA SilentlyContinue )) {
            Write-Output ("No destination folder '{0}' found. Create ..." -f [string](Split-Path $Script:DVBX_INIT_DestRoot -Leaf ) )
            New-Item -ItemType Directory -Force -Path $Script:DVBX_INIT_DestRoot | Out-Null
        }
        else {
            Write-Output ("Destination folder '{0}' exist. Ok." -f [string](Split-Path $Script:DVBX_INIT_DestRoot -Leaf ) )
        }

        # Init/transfer files.
        Write-Output ("Transfer files ...")
        $aCopyFiles.GetEnumerator() | ForEach-Object {
            # Get source and destination full file path to work on.
            $srcFile = $_.Key
            $destFile = $_.Value
            # Get additional path strings.
            $srcFileRelative = $srcFile.Replace($Script:DVBX_INIT_SrcRoot, '') -ireplace '^\\+', '' 
            $destDir = Split-Path -Path $destFile -Parent
            if (!(Test-Path -LiteralPath $destDir -IsValid -EA SilentlyContinue )) {
                throw "Abort: Internal path string not valid: ${$destDir}"
            }
            $destDirRelative = $destDir.Replace($Script:DVBX_INIT_DestRoot, '') -ireplace '^\\+', '' 

            # Create dest directory tree, if needed.
            if (!(Test-Path -LiteralPath $destDir -PathType Container -EA SilentlyContinue )) {
                New-Item -ItemType Directory -Force -Path $destDir | Out-Null
                Write-Output ("Sub-Folder '{0}' created." -f $destDirRelative)
            }

            # Copy/update file.
            Write-Output ("File '{0}' ..." -f $srcFileRelative)
            Copy-Item -LiteralPath $srcFile -Destination $destFile -Force -Container:$false
        }
        
        # Done message.
        Write-Output ("Done.")

    }    
    finally {
        Pop-Location -EA SilentlyContinue
    }    
}
finally {
    Pop-Location -EA SilentlyContinue
}
