# The _DvbxUtiliy_ Variables

## Introduction

Variables are created at the script scope and are used to give back  a so called '_global data_' to user scripts loading the _DvbxUtility_. Most this variables are created read only, but values get updated when _DvbxUtility_ load. The 'Read Only' Option here is just to prevent unintentional change of a value by user script.

### Used Concepts for Variables

The variables has two different so called types of values that differentiate by the usage. They are intended to has constant values or dynamic value, and this can be recognized by the used different naming style and name convention.

The constant values never change between a run or system like a hardcoded value by _DvbxUtility_, and the dynamic values may change on each run, system, or by settings.

**_Name convention of variables:_**

All variables has always a pre-defined capitalized name prefix of the '_Snake Case_' style. For the remaining part of the name a one of the next two styles get used. The '_Pascal Case_' or still '_Snake Case_'.

| Value type |  Prefix   | remaining name style   | Example            |
| :--------: | :-------: | ---------------------- | ------------------ |
|  dynamic   |  `DVBX_`  | pascal case            | DVBX_ValueOfThing  |
|  constanc  | `DVBX_C_` | capitalized snake case | DVBX_C_XY_OF_THING |

### Variables Definitions

Most of them just deliver data to the user script and don't need to be modified. If needed, then the use of a settings file is a better solution.

----

#### Var: `$DVBX_WorkRoot`

_Type:_ String<br>
_Style:_ Dynamic<br>
_Scope:_ Script<br>
_Option:_ Read Only<br>

The path to the project root directory. It get always initialized at the load time by the passed first argument, and it's used for relative paths.

----

#### Var: `$DVBX`

_Type:_ Hashtable<br>
_Style:_ Dynamic<br>
_Scope:_ Script<br>
_Option:_ Read Only

Holds at runtime a hashtable of the current active settings. It is  a full hashtable hierarchy (like in a '_JSON_' file). Each key is a property and the value is a simple value, or an array, or again a hashtable. It get always initialized at the load time.

About the properties and their values look at [the settings](dvbx-settings.md).

----

#### Var: `$DVBX_C_SETTINGS_DIRNAME`

_Type:_ String<br>
_Style:_ Constant<br>
_Scope:_ Script<br>
_Option:_ Read Only<br>

_Value:_ `".dvbx"`<br>

The constant directory name for settings file that _DvbxUtility_ use.

----

#### Var: `$DVBX_C_SETTINGS_FILENAME`

_Type:_ String<br>
_Style:_ Constant<br>
_Scope:_ Script<br>
_Option:_ Read Only<br>

_Value:_ `"dvbx-settings.json"`<br>

The constant filename of the settings file that _DvbxUtility_ use.

----
