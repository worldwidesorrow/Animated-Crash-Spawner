Animated Crash Spawner v1.3.3
==============

I always thought this was a cool server event so I updated it for DayZ Epoch 1.0.6.2, gave it some code optimization, and added some new features.
Updated for DayZ Epoch 1.0.7 on 5-31-2021.

### Updates for DayZ Epoch 1.0.6.2.
* Updated to utilize the new 1.0.6+ loot tables.
* Debug mode enables or disables server rpt diagnostic logs.
* Adjustable mission timeout.
* Lower grass around the loot.
* JIP marker loop (replaces the waitUntil used to detect players).
* Automatically detects the map that you are using and adjusts accordingly.
* Configurable blacklist per map.

### Updated for DayZ Epoch 1.0.7.

### Install Instructions

1. Click ***[Clone or Download](https://github.com/worldwidesorrow/Animated-Crash-Spawner/archive/master.zip)*** the green button on the right side of the Github page.

	> Recommended PBO tool for all "pack", "repack", or "unpack" steps: ***[PBO Manager](http://www.armaholic.com/page.php?id=16369)***
	
2. Unpack your server PBO and place file ***animated_crash_spawner.sqf*** in directory ***dayz_server\modules***

3. Save the file and repack your server PBO

4. Unpack your mission PBO

5. Open ***init.sqf***

	Find this block of code:
	
	```sqf
	EpochEvents = [ //[year,month,day of month, minutes,name of file - .sqf] If minutes is set to -1, the event will run once immediately after server start.
		//["any","any","any","any",-1,"Infected_Camps"], // (negatively impacts FPS)
		["any","any","any","any",-1,"Care_Packages"],
		["any","any","any","any",-1,"CrashSites"]
	];
	```
	
	Add entries to spawn the animated crash spawner like this:
	
	```sqf
	EpochEvents = [ //[year,month,day of month, minutes,name of file - .sqf] If minutes is set to -1, the event will run once immediately after server start.
		//["any","any","any","any",-1,"Infected_Camps"], // (negatively impacts FPS)
		["any","any","any","any",-1,"Care_Packages"],
		["any","any","any","any",-1,"CrashSites"],
		["any","any","any","any",5,"animated_crash_spawner"],
		["any","any","any","any",35,"animated_crash_spawner"]
	];
	```
	
	This will spawn an animated heli/plane crash every 30 minutes while your server is online. The first will spawn at 5 minutes past the hour. Adjust and add entries as desired.
	
6. Repack your mission PBO

	Options: You can configure the animated crash spawner with the following block of defines and variables near the top of the file.

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

Original Author: Grafzahl / Finest
Modified by BushWookie & Forgotten for Epoch
Modified by f3cuk for Epoch 1.0.5.1
Modified by JasonTM for Epoch 1.0.6.2
Modified by JasonTM for Epoch 1.0.7
		


