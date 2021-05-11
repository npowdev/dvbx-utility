# Introduction

DvbxUtility is a little helper set, that is specialized for the Devilbox with Docker. It gives a helpful functionality with concepts to simpliefy the usage of the _Devilbox_ with _Docker_ in other projects.

## The Two Main Parts

It consist of two parts. A set of functions like a library, and some predefined scripts to manage or control the Devilbox for user project.

**1. The _DvbxUtility.ps1_ file:**

This file is the heart part of the DvbxUtility. It's not a module, but a simple PowerShell script for use like a pre loader library inside other scripts.

When it get loaded, it do some base work like initialisation and  checks, and beside the functions set it supply useful data to a loading script.

For more about usage, see below on [How to Use](#how-to-use).

**2. The predefined manage contol scripts set:**

This is a set of ready to use scripts for some base control of Devilbox. All scripts are named with a "dvbx-" prefix, and their filenames look like `dvbx-action-to-do.ps1` for example.

To get more about usage of this scripts, look about [The Scripts](dvbx-scripts.md), and also look below [about file locations](#about-files-and-locations).

## About Files and Locations

The _DvbxUtility_ gets used on a project basis and it's has to get placed into a project directory structure.

**_The Structure in a Project:_**

On a project that uses _DvbxUtility_ the structure looks something like this.

```-
A Project Root Directory
 | ...
 | DvbxUtility           <--> DvbxUtility folder
 |  | DvbxUtility.ps1    <--> the DvbxUtility script
 |  | ...
 | ...
 | ...
 | dvbx-... .ps1         <--> predefined manage control scripts
 | dvbx-... .ps1         <--> ...
 | dvbx-... .ps1         <--> ...
 | ...
 ...
```

The `dvbx-*.ps1` files belong to the predefined manage contol scripts set, they all use `DvbxUtility.ps1` file. They get most placed there in a project so type in and execution in the project terminal get easier.

The `DvbxUtility` folder holds the `DvbxUtility.ps1` file and all other internal files needed. The other provided `dvbx-*.ps1` script files expect also to be able to find this `DvbxUtility.ps1` file there in the project directory.

## How to Use

To use _DvbxUtility_ inside another script, the `DvbxUtility.ps1` file shuld be [loaded inside a user script](#loading-dvbxutilityps1)'s beginning. So all gets prepared for use by this user script. Beside functions definitions, it setup script scope variables and run some internal work.

The load process of _DvbxUtility_ look like this:

- Parses and validates first parameter as path to project/work root directory.
- Checks that Docker is up and running.
- Defines default constant data as readonly variables.
- Defines all functions of this tool set.
- Prepareing needed internal initializations.
- Prepares settings for later use by initialize and prepare of default settings, and then loads user given settings from a file, if any, and updates.
- Does last works preparations to get into the needed running state and to be all ready for use.

Look below for more additional deep information, about [Variables](#about-variables), about [Functions](#about-functions), or about [The Settings](#the-settings) and their usage.

### Loading DvbxUtility.ps1

By concept, as for a script that's not a module, _DvbxUtility_ use a simple PowerShell dot source syntax to be loaded inside another script.

#### Syntax:

```powershell
. (path to DvbxUtility.ps1 file) (directory path)
```

The script needs one positional parameter at load time.

##### Parameter _(directory path)_:

A string value, as the path to the root directory of the project where to work with.

All other required files (like [settings](dvbx-settings.md), etc.) are accessed relative to this path.

#### Example:

There is a script `do-something.ps1`, that has to use _DvbxUtility_. This script is in the root of a project named `some-project`, and the _DvbxUtility_ (`DvbxUtility.ps1` file) is as expected inside a subdirectory of the project named `DvbxUtility`.

So to load it and use it in ``do-something.ps1``, insert the next code at the beginning of script file:

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

> **_Some Code Nontes:_**
>
> - All this mandatory comments around the code are just for a better readability and for separation from following script code.
> - The first dot-source-expression (around the middle) loads now `"$($PSScriptRoot)\DvbxUtility\DvbxUtility.ps1"` with one needed parameter with value from `$PSScriptRoot` ([see below](#psscriptroot-1)).
> - The second line with the if-expression is just a check that everything succeeded, but is optional because DvbxUtility always should throw an exception at load time and failure.
>
> _About use case of `$PSScriptRoot`:_<a name="psscriptroot-1"></a>
>
> Because the script is in the root directory of the project, the example code here uses the value of `$PSScriptRoot` as in this case it is equal to the root project directory. It get used for building path we require to access the DvbxUtility.ps1 file, and also it's value is used for the first required argument.

## About Concepts and Conventions

_DvbxUtility_ don't use the typical PowerShell style of a '_Kebab Case_' name convention, but different name styles concepts to prevent name clashes. The used name style depends of the types they refer to, if it's functions, variables, or constants (_as variabe of constant value_).

### About Variables

_DvbxUtility_ set variables as an type of '_global data_' to be accessible by the user script. This so called '_global data for the user_' get in variables at the script scope. Most of are read only, but values get always updated at every script load.

As usual by concept, there are two different types of values in variables. Variables of a constant value and variables of a dynamic value.

**_Name convention of Variables:_**

Variable naming convention depend on if the value of a variable is dynamic or constant.

All variables has always a pre-defined capitalized name prefix of the '_Snake Case_' style. For the remaining part of the name a one of the next two styles get used. The '_Pascal Case_' or still '_Snake Case_'.

| Value type |  Prefix   | remaining name style   | Example            |
| :--------: | :-------: | ---------------------- | ------------------ |
|  dynamic   |  `DVBX_`  | pascal case            | DVBX_ValueOfThing  |
|  constanc  | `DVBX_C_` | capitalized snake case | DVBX_C_XY_OF_THING |

For more look at [API Variables](dvbx-api-vars.md).

### About Functions

All function names start with a own prefix followed by the remaining part of the name.

**_Name convention of Functions:_**

The functions always uses the '_Pascal Case_' style, by convention.

| Prefix | Name style  | Example        |
| :----: | :---------: | -------------- |
| `Dvbx` | Pascal Case | DvbxDoSomeWork |

For more look at [API Functions](dvbx-api-functions.md).

## The Settings

_DvbxUtility_ offer a simple concept of settings on a project base. There are default settings and an option to modify this settings at runtime from a loadable file (_JSON_) in each project.

This make it open for adoption of some system differentiate but relevant things, like paths or the _Devilbox_ path and needed containers.

For more info look at the [Settings Definition](dvbx-settings.md).
