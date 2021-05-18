# The _DvbxUtiliy_ Settings

## Introduction

_DvbxUtility_ settings work on a project base. This make it open for adaptions on system differentiates and other relevant things, like paths or the _Devilbox_ path and needed containers for example.

The settings has defaults, and at runtime a JSON file of project setting loads over them, if the file is found in special places on that project.

### How to Use Settings

The settings **get access**ible to the user script **by a predefined script scope variable**.

This **settings varable name** is: `$DVBX`.

That variable holds a hashtable as the root of a JSON hirarchy structure. Each a value to a sub-level of the hirarchy is an array or another hashtable also.

For more look at [API Variables](dvbx-api-vars.md).

On load time, it initializes first the default settings. Then if a settings JSON file is found in the project, it is also loading this given user settings from that file.

#### The Settings JSON File:

There are two places in a project where _DvbxUtility_ looks for a settings file. If a settings file is found, it is used to load settings and settings search stops. Othereweise, if no file is found, the default settings stay unnchanged.

**_Expected places of the files and their search order:_**

| Search<br>Order | Filename with Path<br>(_relative to project root_) | File<br>Format |
| :-------------: | :------------------------------------------------- | :------------: |
|       1.        | `.\.dvbx\dvbx-settings.json`                       |     _JSON_     |
|       2.        | `.\.dvbx-settings.json`                            |     _JSON_     |

### Settings Definitions

This are the settings under the `$DVBX` variable as a key/value hashtable hierarchy.

All relative path values are understood relative to the current project's root directory.

----

#### Setting: `$DVBX.SettingsDirName`

The name of the folder for settings file.

_Default:_ `".dvbx"`

> **_Note:_** _As at the moment no support for system wide settings exist, setting this value in a settings file will not change the process of loading any settings, but may change in future releases._

----

#### Setting: `$DVBX.DevilboxPath`

The path to the _Devilbox_ directory. May be relative or absolute.

_Default:_ `"..\..\devilbox"`

----

#### Setting: `$DVBX.LoadServices`

An Array of names (strings) of _Devilbox_ services that should run when the _Devilbox_ container start. If the array is an empty one (like the default value), then all _Devilbox_ services will get run on start.

_Default:_ `@()` _(an empty array)_

----
