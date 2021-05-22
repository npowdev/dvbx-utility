# The _DvbxUtility_ Functions

The _DvbxUtility_ supply a base set of functions for use with the _Devilbox_ by user scripts or by the _DvbxUtility_ own scrips.

## Used Concepts for Function

This functions build a simple lightweight set where some are only for internal use and other also for the user scripts. However, on the easy concept, the access to intern functions is not restricted. To hold usage simple, most use positional parameter. See below at [Function Definitions](#function-definitions) for more.

**_Name convention of function:_**

All function names start with a own prefix followed by the remaining part of the name, and the functions always uses the '_Pascal Case_' style, by convention.

| Prefix | Name style  | Example        |
| :----: | :---------: | -------------- |
| `Dvbx` | Pascal Case | DvbxDoSomeWork |

**_Error handling:_**

Most functions use exceptions for errors and for error handling. So it should always be possible for a user script to do a clean rollback with a try/catch/finally-block. Ofcourse some functions, like for example a test function, don't rise exceptions, but use a return value for error feedback.

## Function Definitions

There is following a detailed list of all functions with everything about parameters, values used or returned, and all about usage of the functions.

----

### Usage: `DvbxGetSettingsFilePathnames`

```-
DvbxGetSettingsFilePathnames
```

**_Returns:_** `[String[]]` (Array of Strings)

Gets the valid full paths of settings files in the current project as an array of strings.

> **_Attention_:_** The returned array is sorted in the order of settings files priority. It should be looked for this files in this order, and the first one that is found should be loaded.

**_Parameters:_** None.

**_Ref:_** None.

----

### Usage: `DvbxGetCurrentSettingsFile`

```-
DvbxGetCurrentSettingsFile
```

**_Returns:_** a `[String]`, may be empty (`""`).

Gets the full path of the first found valid settings file that should be used/loaded. However if no valid settings file is found, than an empty string (`""`) is returned. Never returns a $null value.

**_Parameters:_** None.

**_Ref:_** `DvbxGetSettingsFilePathnames`, `$DVBX_WorkRoot`<br>

----

### Usage: `DvbxReparseCustomObjectsToHT`

```-
DvbxReparseCustomObjectsToHT -Object Value
```

**_Returns:_** the transfered Value.

Reparses the value in parameter `-Object` and converts a value of type `[System.Management.Automation.PSCustomObject]` into type `[System.Collection.Hashtable]`.

It go all down the hierarchy over _Array_ values and the properties of _PSCustomObject_ objects so that each sub-value of type `[PSCustomObject]` is converted. The properties and values of a _PSCustomObject_ object build the key/value-pairs of the new _Hashtable_.

> **_Attention:_** At now, it stops walk down the hierarchy if the value it get is already of type `[Hashtable]`, but that has to change in future versions.

**_Parameters:_**<br>

- **_`-Object Value`:_**<br>A value to work on. Mandatory. Position 0.<br>Accepts values of `$null`, empty strings (`""`), or empty collections (`@{}`).

**_Ref:_** `DvbxReparseCustomObjectsToHT`

----

### Usage: `DvbxLoadJsonFile`

```-
DvbxLoadJsonFile -File filename
```

**_Returns:_** a `[System.Collection.Hashtable]` hashtable.

Loads the _JSON_ file `file` into a hashtable and returns it. The returned hashtable is an hierarchical in memory representation of the _JSON_ file data.

**_Parameters:_**<br>

- **_`-File filename`:_**<br>One filepath (String) to an existing _JSON_ file.<br> Mandatory. Position 0.

**_Ref:_** `DvbxReparseCustomObjectsToHT`

----

### Usage: `DvbxLoadDefaultSettings`

```-
DvbxLoadDefaultSettings [-Settings] ht [-Force]
```

**_Returns:_** None.

Sets the default settings values into the passed collection object.

Only not existing keys will get set, but pass the `-Forse` switch to override this and set all settings regardless of their existence.

**_Parameters:_**<br>

- **_`-Settings ht` (`-S`):_**<br>A collection object of type `[hashtable]` or `[System.Collections.Specialized.OrderedDictionary]` to be filled with settings. Mandatory. Position 0.
- **_`-Force`:_**<br> Optional. A `[switch]`parameter to force set of existing settings.

**_Ref:_** None.

----

### Usage: `DvbxLoadUserSettings`

```-
DvbxLoadUserSettings [-Settings] ht
```

**_Returns:_** None.

Loads user settings values into the passed collection object from a settings file on the project, if file is found.

The loaded setting will update already existing entries on the object, and aleady existing settings not in the file will reamain unchanged.

**_Parameters:_**<br>

- **_`-Settings ht` (`-S`):_**<br>A collection object of type `[hashtable]` or `[System.Collections.Specialized.OrderedDictionary]` to be filled with settings. Mandatory. Position 0.

**_Ref:_** `DvbxGetCurrentSettingsFile`, `DvbxLoadJsonFile`.

----

### Usage: `DvbxIntSettings`

```-
DvbxIntSettings [-Settings] ht
```

**_Returns:_** None.

Initializes the passed collection object to all current settings.

The collection results of a combined collection of the default settings plus the current project setting from a file, if any.

Already existing old entries on the collection object will be removed.

**_Parameters:_**<br>

- **_`-Settings ht` (`-S`):_**<br>A collection object of type `[hashtable]` or `[System.Collections.Specialized.OrderedDictionary]` to be initialized with settings. Mandatory. Position 0.

**_Ref:_** `DvbxLoadDefaultSettings`, `DvbxLoadUserSettings`.

----
