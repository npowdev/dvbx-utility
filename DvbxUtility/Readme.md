# The DvbxUtility - A Devilbox Helper Toolset

The DvbxUtility is a litle tool set, like a library, specialized for the Devilbox.

## The DvbxUtility.ps1

The DvbxUtility.ps1 file is the heart of DvbxUtility. It's not a module, but a simple PowerShell script for use inside other PowerShell helper scripts.

DvbxUtility give to us a collection of helpful functions and workflow tasks to make work with Devilbox and Docker easy in other projects. Wenn it get loaded, it make also some base check and initialisation, and suply usefull data and tools about Devilbox and Docker.

## How To Use

### How to load DvbxUtility.ps1

The source code has to be loaded with PowerShell dot source syntax inside the beginning of another scripts.

**_Syntax:_**

```powershell
. (path to DvbxUtility.ps1 file) (directory path)
```

**_Argument:_**

The script needs just one positional argument at load time. A string, with the root path of the project where we are use it.

**_Load Example:_**

Let's take as example that situation:

- We write a new script ``do-something.ps1``, that should use DvbxUtility.
- This script is in the root of a project named ``some-project``.
- The DvbxUtility is in a direct project subdirectory named ``DvbxUtility``.

To load and use DvbxUtility in ``do-something.ps1``, insert the following code snippet at the beginning of our script file:

```powershell
########################################################################
# Load Base Tool: DvbxUtility
########################################################################
. "$($PSScriptRoot)\DvbxUtility\DvbxUtility.ps1" $PSScriptRoot
if (!$?) { Write-Error -Message "Load of DvbxUtility may has failed!" -EA Stop }

########################################################################
# Script code that use DvbxUtility start here
########################################################################
```

The line with dot sorce expression about the middle of that examle loads ``$($PSScriptRoot)\DvbxUtility\DvbxUtility.ps1`` file with the one needed argument with value from ``$PSScriptRoot`` ([see note below](#note-psscriptroot-1)).

The next line with the if-expression is a check that everything succeeded, but is optional because DvbxUtility always should throw an exception on failure at load time.

The comments all around are just for a better readability and for separation from the following script code.

> _Notes about ``$PSScriptRoot``:_<a name="note-psscriptroot-1"></a>
>
> As ours script is in the root directory, we use here the value of this variable, as the root part and for later building of relative paths. Also we use it as the value for the first argument, as it give us the path of the project.

## What happens when DvbxUtility is loading

The DvbxUtility run some internal base work at loading into a script:

1. Doing some base work.
   - Parsing and validating first parameter.
   - Checks that Docker is up and running.
2. Defining tool set of functions and some constant data.
3. Prepareing needed internal initializations.
4. Retrieving setting for use internaly and externaly by user by:
   - Collecting default settings data.
   - Updateing settings data by loading from an optional user settings file.
5. Prepares that data at script scope and is ready for use.

## The tool set of functions and data

The script don't use the PowerShell typical Kebab Case like style, but the following styles and names concepts:

### Functions

All functions uses **Pascal Case** style, and all function names start with **'Dvbx'** followed by the rest of the name.

For more info look at the [API Functions](dvbx-api-functions.md).

### Interfce Variables

Data is passed for use by the user in script scope variables. Most of the variables are defined as read only, but get always updated at every script load.

For more info look at the [API Interface Varables](dvbx-api-vars.md).

## Settings

TODO: Short intro recription.

For more info look at the [Settings Definition](dvbx-def-settings.md).

## Concepts of use in other scripts

TODO: Intro to concepts.

For more info look at the (TODO: _Link_).
