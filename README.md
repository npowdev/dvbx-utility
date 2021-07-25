# DVBX Utility

The _DVBX Utility_ give a set of _PowerShell_ scripts to simplify and speedup the usage of _Devilbox_ with _Docker_ on a per project base. As all scripts use a source-load base script like a base library, it's a littlebit extendible and may be used for other own scripts.

## Get Started

_DVBX Utility_ consist of folowing main parts:

- Everyday usage script files in root folder,
- A subdirectory with the source-load base library script needed by all this scripts.
- An init script (also in root folder) to prepare scripts for usage in other/new project folders by copy.
- Some Markdown files as docomentation, but not needed for run.

In [deep documentation](DvbxUtility/Readme.md) for later invesigation about _DVBX Utility_ is to be found in the 'DvbxUtility' subfolder.

Look now about base steps how to get it ready and use then.

---

### How to get _DVBX Utility_

To use the tool no installation is needed as it works on a per project basis. All needed is a local copy of the scripts or the repo.

The simple way to get it, is over a git clone copy of this repo. This give an easy way to get later updates just by a `git pull` call.

Proceed with next step below to initialize and [integrate the scripts in a project](#how-to-integrate-it-in-a-project).

### How to Integrate it in a Project

For an initialization or integration of the _DVBX Utility_ scripts in a project where they should work in, they all have to get in that folder.

Beside the possibility of doing that by hand, doing that by the [init script](DvbxUtility/dvbx-scripts.md#Script-dvbx-init.ps1) already provided by _DVBX Utility_ is the right way.

#### With the Provided Script ([dvbx-init.ps1](DvbxUtility/dvbx-scripts.md#Script-dvbx-initps1))

##### Usage:

```powershell
dvbx-init.ps1 [<directory name or path to>]
```

> **_Example:_** <a id="fex_dvbxinit_call"></a>
>
> Lets say the _DVBX Utility_ have to be setup for usage in project 'my-project', and there is already a local copy of _DVBX Utility_ somewhere.
>
>In a PowerShell console call:
>
> ```powershell
> X:\path\somewhere PS> path\to\local\of\dvbx-init.ps1 'my-project'
> ```
>
> This will copy all needed files to the directory 'my-project' in the current working directory. The 'my-project' directory there will be created, if doesn't exist already.

The one alone argument is optional, and without one, then the script works in the current directory. Usage of a relative path or single name ([like above](#fex_dvbxinit_call)) is then also depending from the current working directory.

**_Note:_** The script works only with the FileSystem Provider on local files and folders, and for use of a relative path or name also the current working directory have to be set there.

> **_Attention:_** As by the script files get copied, files with same name will get silenty overwritten, withon user interaction or confirmation!

#### Things to investigate next from here:

- In the next section below is a importand view over files and how to [integrate by hand](#integrate-by-hand-without-provided-script) without the provided script.
- All about all the scripts and their usage also is [here](DvbxUtility/dvbx-scripts.md) to read directly.
- In the [more deep documentation](DvbxUtility/Readme.md) with furter links about work and usage is found in the Markdowns in the 'DvbxUtility' folder.
- Info of the API in the base library script and about [vars](DvbxUtility/dvbx-api-vars.md), [functions](DvbxUtility/dvbx-api-functions.md) is also found there.
- Info about [settings](DvbxUtility/dvbx-settings.md) implementation, their usage, and how integrate in a project is also found there.

---

#### Integrate by Hand (without Provided Script)

To do it by hand, all we have to do is to copy all needed scripts of the _DVBX Utility_ in the root folder of a project. We have also to absolutely not foret to copy the 'DvbxUtility' subfolder.

##### Files, Folders, and the Structure:

With a short look at the local git clone copy of _DVBX Utility_ we will found this files and structure:

```-
Root directory of our DVBX Utility copy/clone
| ...
|-DvbxUtility           <--> DVBX Utility folder
| | DvbxUtility.ps1     <--> the source-load base library script
| | ...
| ...
| dvbx-init.ps1         <--> the DVBX Utility init script
| dvbx-... .ps1         <--> other predefined DVBX Utility scripts
| dvbx-... .ps1         <--> ...
| dvbx-... .ps1         <--> ...
| ...
```

If a project has to use _DVBX Utility_, copy the needed files into the project and on same places. All needed are `*.ps1` files in the root directory, and the one script in the subdirectory.

- All the `dvbx-*.ps1` files in root directory are the commands for evryday usage and must get copied.
- However the `dvbx-init.ps1` file there is an exception and shuld get skipped, as it's just for initialization and not needed in a project.
- The next that must get copied the 'DvbxUtility' subdirectory, because all other scripts use `DvbxUtility\DvbxUtility.ps1` file as source-loaded base script library.

Scripts rely on their position in a project directory as they are using relative path to load the base script library, and some additionally also have to call each other.

> **_Note:_** In the 'DvbxUtility' folder are some files of other type like markdown files, but they are not needed for functionality and may be removed on a project. Markdown files are most used for documentation purpose.

---
