# Factorio: Map Seed Scanner (mod)

A functional example mod for scanning different map generatation settings for various qualities. The mod has limited in-game controls and should be adjusted or expanded by modifying the code.

The logger will default output to ```script-output\MapSeedScanner\seed_SEEDNUMBER.log```



## Installation

Clone this repository to the factorio mods folder ```mods/map-seed-scanner_1.0.0```

or

Download the zip of this repository and place in the factorio mods folder.

* Factorio loads mods from folders just like zip files. It's recommended to keep this mod in a folder to be able to modify the files easily.
* This mod is not available on the official portal.
* Make sure to disable the mod with the in-game mods menu while not using it.

## analyzer.lua

The ```analyzer.lua``` file contains two important functions that need to be modified to the search you want. 
1. ```iterate``` function is called to determine the next seed to scan. Return the ```map_generation_settings``` to scan next or ```false``` to stop the scanner.
2. ```validate``` function tests the properties of the map once it has been generated. Return ```true``` to add the map as a match, return ```false``` to ignore it and continue to next seed.

Note that you can modify mod files while factorio is running in the main menu, ```control.lua``` doesn't get loaded until you start a map.

## Console Commands

```/scanner start```

Start scanning map seeds.

```/scanner stop```

Stop/pause scanning map seeds.

```/scanner status```

Print information about the current or most recent scans to the console.

```/scanner goto N```

Teleports the player to map match N. N should be a number from 1 to the number of matches found.

```/scanner reset```

Resets the global.map_gen_settings to the original map generation settings from when the game was started.

```/scanner watch```

Teleport the player to see each map generated. Can help with debugging but slows down the scanner with rendering.

```/scanner matches_dump```

Dumps the matched map exchange strings to ```script-output\MapSeedScanner\matches_dump.lua``` this file can replace the ```matches_dump.lua``` in the mod folder to initialize the mod with matches.

```/scanner log STR```

Write STR (string) to the active log file.

```/scanner exchange_string```

Opens a small GUI to copy the active map_exchange_string.

```/scanner seed```

Opens a small GUI to copy the active map seed.

## Globals

```global.chunk_radius``` (number) chunks located (x, y) will be generated from (-N, -N) to (N, N) before validating.

```global.match_results``` (table) list of map exchange strings that validated true.

```global.map_gen_settings``` (string) the map exchange string of the last scanned map.


## Changing global from the console

Remember you can access a mods global table through the console like this:

```/c __map-seed-scanner__.global.match_results = {}```