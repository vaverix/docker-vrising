#!/bin/bash

s=/mnt/vrising/server
p=/mnt/vrising/persistentdata
m=/mnt/vrising/mods

header="[<<<<<<<<<<<<<<<<<<<]"

mkdir -p /root/.steam 2>&1

echo "${header} Updating V-Rising Dedicated Server files..."
/usr/bin/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$s" +login anonymous +app_update 1829350 validate +quit

if ! grep -q -o 'avx[^ ]*' /proc/cpuinfo; then
	unsupported_file="VRisingServer_Data/Plugins/x86_64/lib_burst_generated.dll"
	echo "${header} AVX or AVX2 not supported; Check if unsupported ${unsupported_file} exists.."
	if [ -f "${s}/${unsupported_file}" ]; then
		echo "${header} Changing ${unsupported_file} as attempt to fix issues..."
		mv "${s}/${unsupported_file}" "${s}/${unsupported_file}.bak"
	fi
fi

mkdir -p "$p/Settings"
if [ ! -f "$p/Settings/ServerGameSettings.json" ]; then
	echo "${header} $p/Settings/ServerGameSettings.json not found. Copying default file..."
	cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" "$p/Settings/" 2>&1
fi
if [ ! -f "$p/Settings/ServerHostSettings.json" ]; then
	echo "${header} $p/Settings/ServerHostSettings.json not found. Copying default file..."
	cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" "$p/Settings/" 2>&1
fi

echo "${header} Cleaning  up old mods (if any).."
rm -rf "$s/BepInEx"
rm -rf "$s/dotnet"
rm -f "$s/doorstop_config.ini"
rm -f "$s/winhttp.dll"

if [ -n "$ENABLE_MODS" ]; then
  echo "${header} Setting up mods..."
  cp -r  "$m/BepInEx"             "$s/BepInEx"
  cp -r  "$m/dotnet"              "$s/dotnet"
  cp     "$m/doorstop_config.ini" "$s/doorstop_config.ini"
  cp     "$m/winhttp.dll"         "$s/winhttp.dll"
  export WINEDLLOVERRIDES="winhttp=n,b"
fi

echo "${header} Starting V Rising Dedicated Server with name ${SERVERNAME=vrising-dedicated}..."
echo "${header} Trying to remove /tmp/.X0-lock..."
rm -f /tmp/.X0-lock 2>&1


echo "${header} Generating initial Wine configuration..."
winecfg
sleep 5

echo "${header} Starting Xvfb"
Xvfb :0 -screen 0 1024x768x16 &

echo "${header} Launching wine64 V Rising"

exec env DISPLAY=:0.0 wine64 /mnt/vrising/server/VRisingServer.exe -persistentDataPath $p -logFile "$p/$(date +%Y%m%d-%H%M)-VRisingServer.log" 2>&1