Animated Crash Spawner v1.3.3
==============

I always thought this was a cool server event so I updated it for DayZ Epoch/Overpoch 1.0.6.2, gave it some code optimization, and added some new features.

### Updates for DayZ Epoch/Overpoch 1.0.6.2.
* Updated to utilize the new 1.0.6+ loot tables.
* Debug mode enables or disables server rpt diagnostic logs.
* Adjustable mission timeout.
* Lower grass around the loot.
* JIP marker loop (replaces the waitUntil used to detect players).
* Automatically detects the map that you are using and adjusts accordingly.
* Configurable blacklist per map.

This mod works with maps: Chernarus, Lingor, Sahrani, Panthera, Namalsk, Taviana, Napf, Sauerland, and Takistan.

### Install Instructions

1. Click ***[Clone or Download](https://github.com/worldwidesorrow/Animated-Crash-Spawner/archive/master.zip)*** the green button on the right side of the Github page.

	> Recommended PBO tool for all "pack", "repack", or "unpack" steps: ***[PBO Manager](http://www.armaholic.com/page.php?id=16369)***
	
2. Unpack your server PBO and place file ***animated_crash_spawner.sqf*** in directory ***dayz_server\modules***

3. Since you are installing animated crashes, I recommend that you disable the DayZ Vanilla crash spawner. To do this, edit file ***dayz_server\system\server_monitor.sqf*** with notepad++

	Find this line:
	
	```sqf
	[] execVM "\z\addons\dayz_server\compile\server_spawnCrashSites.sqf";
	```
	
	and comment it out so it looks like this:
	
	```sqf
	//[] execVM "\z\addons\dayz_server\compile\server_spawnCrashSites.sqf";
	```

4. Save the file and repack your server PBO

5. Unpack your mission PBO

6. Edit ***init.sqf*** with notepad++

	Find this line:
	
	```sqf
	EpochUseEvents = false;
	```
	
	Change it to true, if not already:
	
	```sqf
	EpochUseEvents = true;
	```
	
	Find this line right below:
	
	```sqf
	EpochEvents = [["any","any","any","any",30,"crash_spawner"],["any","any","any","any",0,"crash_spawner"],["any","any","any","any",15,"supply_drop"]];
	```
	
	Replace it with this. If you already have other entries work these in.
	
	```sqf
	EpochEvents = [["any","any","any","any",5,"animated_crash_spawner"],["any","any","any","any",35,"animated_crash_spawner"]];
	```
	
	This will spawn an animated heli/plane crash every 30 minutes while your server is online. The first will start after the server has been online for 5 minutes.
	Note: The old Epoch crash_spawner and supply_drop events are no longer being used in DayZ Epoch 1.0.6+ so we remove them from the EpochEvents array.
	
7. Copy the ***dayz_code*** folder over to your mission folder.

8. This mod is dependent on the Epoch community stringtable. Download the stringtable ***[here](https://github.com/oiad/communityLocalizations/)*** and place file stringTable.xml in the root of your mission folder.
	
9. Repack your mission PBO

	Options: You can configure the animated crash spawner with the following block of defines and variables.

	```sqf
	// Configs - You can adjust these
	#define DEBUG_MODE 		false  	// Adds diagnostic entries to the server rpt
	#define CRASH_TIMEOUT 	1200	// The amount of time it takes for the mission to time out if no players show up
	#define SPAWN_CHANCE 	100	 	// Percent chance of spawning a crash number between 0 - 100 
	#define GUARANTEED_LOOT	16	 	// Guaranteed Loot Spawns
	#define RANDOM_LOOT		8		// Random number of loot piles as well as the guaranteed ones
	#define SPAWN_FIRE 		true 	// Spawn Smoke/Fire at the helicrash
	#define FADE_FIRE 		false	// Fade the Smoke/Fire overtime
	#define PREWAYPOINTS 	2		// Amount of way points the heli flies to before crashing
	#define MIN_LOOT_RADIUS 4	 	// Minimum distance for loot to spawn from the crash site in meters
	#define MAX_LOOT_RADIUS 10	 	// Maximum distance for loot to spawn from the crash site in meters
	#define MARKER_RADIUS 	400	 	// Radius for the marker
	#define SHOW_MARKER		true	// Show a marker on the map
	#define MARKER_NAME 	true	// Add the crash name to the marker, SHOW_MARKER must be true
	#define LOWER_GRASS		true	// lowers the grass around the loot
	_crashDamage			= 1;	// Amount of damage the heli can take before crashing (between 0.1 and 1) Lower the number and the heli can take less damage before crashing 1 damage is fully destroyed and 0.1 something like a DMR could one shot the heli
	_exploRange				= 200;	// How far away from the predefined crash point should the heli start crashing
	```
	
	
	
	You can also configure the blacklist for each map if you don't want crashes to land in certain areas of the map. Each of the maps listed in the call function has an entry like this:

	```sqf
	_blackList = [];
	```

Add coordinates similar to the Chernarus entry. The explanation for blacklist is found in ***[BIS_fnc_selectRandom](https://community.bistudio.com/wiki/BIS_fnc_findSafePos)***

This server event uses ***[This Crashsite Loot Table](https://github.com/EpochModTeam/DayZ-Epoch/blob/master/SQF/dayz_code/Configs/CfgLoot/Groups/CrashSite.hpp)*** Every crash spawn chooses one of the groups at random. If you want custom loot then you can customize the loot in this file.


### Credits

Credits are listed in the animated_crash_spawner.sqf file itself and additional credits were given to Richie and BetterDeadThanZed by F3cuk for heli start points on maps other than Chernarus.
		


