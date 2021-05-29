# The _DvbxUtiliy_ Base Scripts

This is a supported set of scripts for simple _Devilbox_ control, and all scripts are ready to use by needs, but not necessary.

## How to Use the Scripts

As the _DvbxUtility_ gets used on a project basis, all this scripts we want to use has to get placed into the projects root directory.

> **_Note:_** All scripts are named with a "dvbx-" prefix, followed by the action they do, and all names use the '_Kebab Case_' style.

On a project that uses _DvbxUtility_ do the following:

1. Place a copy of the script you want to use in the project root directory,
2. Place a copy of the `DvbxUtility.ps1` file to `DvbxUtility\DvbxUtility.ps1` there too,

and now this `dvbx-*.ps1` scripts there are ready for use.

They get most placed there in a project so type in and execution in the project terminal get easier.

All the scripts depend only on the `DvbxUtility.ps1` file in `DvbxUtility\DvbxUtility.ps1` on the project directory, and they don't depend on each other or other things else.

If not otherwise defined, all scripts temporary change the current location as they need to be inside the _Devilbox_ directory to work with, and the previous location is restored when they get ready.

## The Supported Scripts

The scripts are designed for simplicity and don't need any parameters as they make use _DvbxUtility_ and the option of settings by project. However some give the option to use arguments to temporary change their behavior. Offcourse all scripts loads `DvbxUtility\DvbxUtility.ps1` from the project directory.

----

### Script: dvbx-up.ps1

Starts up the _Devilbox_ and makes it use ready, as with `docker-compose.exe "up"` command.

The Devilbox containers that start are determined from settings.

----

### Script: dvbx-down.ps1

Stops and turn off the _Devilbox_ completely as with `docker-compose.exe "down"` command.

----

### Script: dvbx-restart.ps1

Restarts all (maybe) running containers of Devilbox in a clean complete round trip.

It stops all, then removes the containers, and start up again the Devilbox with the containers determined from settings.

> **_Note:_** like with a sequence of `docker-compose.exe "stop"`, `docker-compose.exe "rm" -f`, and `docker-compose.exe "up"` command.

----

### Script: dvbx-go-devilbox.ps1

Just simply to go to the Devilbox directory and work there.

> **_Attention:_** The script don't restore the previous location! However, it uses the `Push-Location` command and the stack. So to go back, all  have to (and should) be done is a call to `Pop-Location` / `popd`.

----

### Script: dvbx-shell.ps1

Enters the _Devilbox_ shell command prompt.

> **_None_:** To get back simply exit that shell.

Internally the script uses `shell.bat` delivered by the _Devilbox_ to get into the command line prompt inside the current php container.

----
