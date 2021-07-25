# The concept of DVBX Utility

As a little helper scripts set, the _DVBX Utility_ gives a helpful functionality to simpliefy the usage of the _Devilbox_ with _Docker_ in other projects, and it's done with a certrialized script part like a library.

## The Main Parts

- Init scripts to prepare for usage in other/new projects.
- An extendible set of everyday usage script files.
- A subdirectory with a source-load base library script.
- Documentation in Markdown files.

**The init scripts:**

At now there is just init script `dvbx-init.ps1` in root folder that prepare the rest for usage on a given other/new project by copying there all needed. See [here](dvbx-scripts.md#Script-dvbx-init.ps1) about.

**The set of everyday usage script files:**

This is a colection of ready to use scripts in the root directory for the control of _Devilbox_, and all this scripts has a sort of name convention to avoid conflicts in projects.

As convention, the names use just easy a constant prefix followed by the action or work a script does. All names are in lower case, and names use dash for word separation and inplac of spaces.

- Prefix part: `dvbx-`
- Action/work: a verb or short  action description

For example like: `dvbx-start-up.ps1`, `dvbx-go-down.ps1`, etc.

Look [here](dvbx-scripts.md) for more about scripts and each ones usage. Also [look below](#about-files-and-locations) for more about files locations.

**The base library scrip file:**

It's the heart part of the _DVBX Utility_, and it's the `DvbxUtility.ps1` file in a own subdirectory.

By concept it's just a simple _PowerShell_ script for use like a pre loader library inside other scripts. It's not a module. When it get loaded, it do some base work like initialisation and  checks, and beside the functions set it supply useful data to loading script.

For more about usage, see below on [how to use](#how-to-use-the-library-script) and also below about [file location](#about-files-and-locations).

## About Files and Locations

The _DVBX Utility_ gets used on a project basis and it's has to get placed into each project directory structure.

**_The Structure in a Project:_**

On a project that uses _DVBX Utility_ the structure looks something like this.

```-
In a project's root directory
| ...
|-DvbxUtility           <--> DVBX Utility folder
| |-DvbxUtility.ps1     <--> the source-load base library script
| | ...
| ...
| dvbx-... .ps1         <--> other predefined DVBX Utility scripts
| dvbx-... .ps1         <--> ...
| dvbx-... .ps1         <--> ...
| ...
```

The `dvbx-*.ps1` files belong to the everyday usage script files set. They all use `DvbxUtility.ps1` file.

The `DvbxUtility` directory holds the `DvbxUtility.ps1` file, and also some markdown documentation, but not needed for run.

The provided `dvbx-*.ps1` scripts need this `DvbxUtility.ps1` file and expects to find it in a `DvbxUtility` subfolder in each project directory they get loadet from.

So all this must get placed there in a project. Placed in the root of a project, this make easy a type-in and execution on the projects console.

## How to Use the Library Script

To use _DVBX Utility_ inside another script, the `DvbxUtility.ps1` file shuld be [loaded inside a user script's](#loading-dvbxutilityps1) beginning. So all gets prepared for use by this user script. Beside functions definitions, it setup script scope variables and run some internal work.

The load process of _DVBX Utility_ look like this:

- Parses and validates first parameter as path to project/work root directory.
- Checks that Docker is up and running.
- Defines default constant data as readonly variables.
- Defines all functions of this tool set.
- Prepareing needed internal initializations.
- Prepares settings for later use by initialize and prepare of default settings, and then loads user given settings from a file, if any, and updates.
- Does last works preparations to get into the needed running state and to be all ready for use.

Look below for more additional deep information, about [Variables](#about-variables), about [Functions](#about-functions), or about [The Settings](#the-settings) and their usage.

### Loading DvbxUtility.ps1

By concept, as for a script that's not a module, _DVBX Utility_ use a simple _PowerShell_ dot source syntax to be loaded inside another script.

#### Syntax:

```powershell
. (path to DvbxUtility.ps1 file) (directory path)
```

The script needs one positional parameter at load time.

##### Parameter _(directory path)_:

This is a string value, as the path to the root directory of the project where to work with.

All other required files (like [settings](dvbx-settings.md), etc.) are accessed relative to this path.

#### Example:

There is a script `do-something.ps1`, that has to use _DVBX Utility_. This script is in the root of a project named `some-project`, and the `DvbxUtility.ps1` file of the  _DVBX Utility_ is as expected inside a subdirectory named `DvbxUtility` in that project.

So to load it and use it in ``do-something.ps1``, insert the next code at the beginning of script file:

```powershell
########################################################################
# Load Base Tool: DVBX Utility
########################################################################
. "$($PSScriptRoot)\DvbxUtility\DvbxUtility.ps1" $PSScriptRoot
if (!$?) { Write-Error -Message "Load of DVBX Utility may has failed!" -EA Stop }

########################################################################
# Script code that use DVBX Utility start here
########################################################################
```

> **_Some Code Nontes:_**
>
> - All this mandatory comments around the code are just for a better readability and for visual separation from code.
> - The dot-source-expression in the middle loads now `"$($PSScriptRoot)\DvbxUtility\DvbxUtility.ps1"` with one needed parameter that get value from `$PSScriptRoot` ([see below](#psscriptroot-1)).
> - The next line with the if-expression is just a check that everything succeeded, but is optional because _DVBX Utility_ always should throw an exception if something went wrong on load time.
>
> _About use case of `$PSScriptRoot`:_<a name="psscriptroot-1"></a>
>
> Because the script is as expected in the root directory of the project in the example, the code here uses the value of `$PSScriptRoot` as in this case it's equal to the root project directory. It get used for building the path we require to access the `DvbxUtility.ps1` file.

## About internal Concepts and Conventions

_DVBX Utility_ don't use the typical _PowerShell_ style of a '_Kebab Case_' name convention, but different name styles concepts to prevent name clashes. The used name style depends of the types they refer to, if it's functions, variables, or constants (_as variabe of constant value_).

### About Variables

_DVBX Utility_ set variables like a type of global data that is accessible for a user script. This so called global data variables are at _PowerShell_ scope at script level.

There are by concept two different sort of kinds of variables by the attributes of their value, and the so used naming style depends on that.

For more look at [API Variables](dvbx-api-vars.md).

### About Functions

The functions that _DVBX Utility_ supply are a set of helper functions for user scripts and itself. All function names start with a prefix followed by the remaining part of the name, and has an own name convention style.

For more look at [API Functions](dvbx-api-functions.md).

## The Settings

_DVBX Utility_ offer a simple system for own settings on a project base. There are default settings and an option to modify this settings at start with a loadable settings file (_JSON format_) by each project.

This make it open for customization of some system different but relevant things, like paths as for example the _Devilbox_ path and needed containers.

For more info look at the [Settings Definition](dvbx-settings.md).

---
