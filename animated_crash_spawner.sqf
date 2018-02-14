/*
	Script Name: animated_crash_spawner.sqf
	Original Author: Grafzahl / Finest
	Modified by BushWookie & Forgotten for Epoch
	Modified by f3cuk for Epoch 1051
	Modified by JasonTM for Epoch 1062
	Script Version: 1.3.3
*/
 
private["_exploRange","_blackList","_lootArray","_crashSelect","_ran15","_missionEnd","_isClose1","_isClose2","_isClose3","_inFlight","_plane","_porh","_lootVeh","_finder","_crash","_crashDamage","_preWaypointPos","_endTime","_startTime","_heliStart","_heliModel","_lootPos","_wp2","_landingzone","_aigroup","_wp","_helipilot","_crashwreck","_pos","_dir","_mdot","_position","_num","_crashModel","_crashName","_marker","_itemTypes"];

#include "\z\addons\dayz_code\loot\Loot.hpp"

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

//Parameters for finding a suitable position to spawn the crash site
#define SEARCH_CENTER getMarkerPos "crashsites"
#define SEARCH_RADIUS (getMarkerSize "crashsites") select 0
#define SEARCH_DIST_MIN 20
#define SEARCH_SLOPE_MAX 2

// Initialize mission variables - DO NOT CHANGE THESE
_ran15		= 0;
_isClose1	= false;
_isClose2	= false;
_isClose3	= false;
_inFlight 	= true;
_missionEnd	= false;
_lootArray	= [];

// Do not change below values if you do not know what you are doing
_crashSelect = [["UH1Y_DZE","UH1YWreck",false],["MV22","MV22Wreck",false],["Mi17_DZ","Mi17Wreck",false],["UH60M_EP1","MH60Wreck",false],["UH60M_MEV_EP1","MH60Wreck",false],["A10","A10Wreck",true],["Ka52Black","Ka52Wreck",false],["Mi24_D","Mi24Wreck",false],["AH1Z","AH1ZWreck",false],["AV8B","AV8BWreck",true],["Su25_TK_EP1","SU25Wreck",true]] call BIS_fnc_selectRandom;
_heliModel	 = _crashSelect select 0;
_crashModel	 = _crashSelect select 1;
_plane		 = _crashSelect select 2;
_porh		 = "helicopter";
_crashName	 = getText (configFile >> "CfgVehicles" >> _heliModel >> "displayName");
#define SPAWN_ROLL round(random 100)

call
{
	if (toLower worldName == "chernarus") exitWith {_blackList = [[2092,14167],[10558,12505]]; _heliStart = [[1000.0,2.0],[3500.0,2.0],[5000.0,2.0],[7500.0,2.0],[9712.0,663.067],[12304.0,1175.07],[14736.0,2500.0],[16240.0,5000.0],[16240.0,7500.0],[16240.0,10000.0]] call BIS_fnc_selectRandom;};
	if (toLower worldName == "namalsk") exitWith {_blackList = []; _heliStart = [[5046.9678, 5943.2656],[6360.792, 6582.0723],[3544.4153, 6451.7793],[7504.9102, 5786.3271],[7752.436, 7067.6895],[3920.3354, 7530.4941],[6448.9805, 8406.374],[6098.7876, 10094.43],[4745.8853, 10273.457],[8271.7441, 10356.828]] call BIS_fnc_selectRandom;};
	if (toLower worldName == "panthera") exitWith {_blackList = []; _heliStart = [[2354.8118, 2898.7732],[6441.2544, 604.39148],[5837.6265, 3852.1699],[3434.9966, 7324.9521],[1250.1727, 8301.4199],[6353.0869, 5563.6592],[3011.1584, 4440.96],[4967.9551, 6376.479],[8340.8125, 4563.1436],[4582.7534, 2080.5737]] call BIS_fnc_selectRandom;};
	if (toLower worldName == "tavi") exitWith {_blackList = []; _heliStart = [[11558.516, -56.829834],[7787.207, 3972.2046],[2279.2651, 6822.7891],[5548.9434, 8449.1914],[9465.4697, 7223.2925],[17441.467, 5454.5791],[13474.444, 11853.039],[8848.6611, 18823.994],[16224.908, 13310.733],[15171.845, 7629.0879]] call BIS_fnc_selectRandom;};
	if (toLower worldName == "lingor") exitWith {_blackList = []; _heliStart = [[862.89911, 816.75781],[2884.9204, 1093.1793],[3923.7927, 1078.5016],[6571.9326, 1575.0684],[3046.9241, 2413.4119],[5652.1348, 2944.7871],[1866.0063, 4954.5566],[3748.3994, 5456.0498],[6348.8232, 4448.1694],[8368.7148, 7673.5293]] call BIS_fnc_selectRandom;};
	if (toLower worldName == "napf") exitWith {_blackList = []; _heliStart = [[3458.7625, 2924.917],[11147.994, 1516.9348],[14464.443, 2533.0981],[18155.545, 1416.5674],[16951.584, 5436.3516],[16140.807, 12714.08],[14576.426, 14440.467],[8341.2383, 15756.525],[2070.4771, 8910.4111],[16316.533, 17309.357]] call BIS_fnc_selectRandom;};
	if (toLower worldName == "smd_sahrani_a2") exitWith {_blackList = []; _heliStart = [[14266.4,3304.66],[19063.1,6824.15],[6688.1,1587.49],[1664.31,7065.41],[4601.96,11620.9],[1750.87,15409.3],[4163.02,19624.9],[10003.3,20040.9],[19203.8,17416.8]] call BIS_fnc_selectRandom;};
	if (toLower worldName == "sauerland") exitWith {_blackList = []; _heliStart = [[3143.7053, 519.72656],[14047.064, 736.25336],[19551.301, 1638.9634],[22871.928, 3194.9937],[3216.1506, 8066.9844],[15430.821, 7462.8496],[22722.418, 8578.207],[3399.9622, 13945.776],[16220.508, 14363.767],[10220.176, 18679.586]] call BIS_fnc_selectRandom;};
	if (toLower worldName == "takistan") exitWith {_blackList = []; _heliStart = [[2877.6855, 703.94592],[7118.8374, 10659.661],[7281.5488, 690.51361],[9251.5283, 2722.7166],[3742.7253, 3439.4333],[1300.1748, 3303.4463],[6000.7114, 5670.394],[9339.2139, 6650.0625],[11687.854, 9396.415],[3025.9387, 9983.293]] call BIS_fnc_selectRandom;};
};

if (DEBUG_MODE) then {diag_log(format["CRASHSPAWNER: %1%2 chance to start a crashing %3", SPAWN_CHANCE, '%', _crashName]);};

if (SPAWN_ROLL <= SPAWN_CHANCE) then
{
	if(_plane) then {
		_porh = "plane";
	};
	
	[nil,nil,rTitleText,format["A %1 is in distress! Watch for it and go to the crash site to secure the loot!",_porh], "PLAIN",10] call RE;
	
	_position = [SEARCH_CENTER, 0, SEARCH_RADIUS, SEARCH_DIST_MIN, 0, SEARCH_SLOPE_MAX, 0, _blackList] call BIS_fnc_findSafePos; //SEARCH_BLACKLIST
	_position set [2, 0];
	
	if (DEBUG_MODE) then {diag_log(format["CRASHSPAWNER: %1 started flying from %2 to %3 NOW!(TIME:%4)", _crashName,  str(_heliStart), str(_position), round(time)]);};
	
	_startTime 		= time;
	_crashwreck 	= createVehicle [_heliModel,_heliStart, [], 0, "FLY"];
	dayz_serverObjectMonitor set [count dayz_serverObjectMonitor,_crashwreck];
	_crashwreck 		engineOn true;
	_crashwreck 		flyInHeight 150;

	if (_plane) then
	{
		_crashDamage = .5;
		_crashwreck setDamage .4;
		_crashwreck forceSpeed 250;
		_crashwreck setspeedmode "LIMITED";
	}
	else
	{
		_crashwreck forceSpeed 150;
		_crashwreck setspeedmode "NORMAL";
	};
	
	_landingzone 	= createVehicle ["HeliHEmpty", [_position select 0, _position select 1,0], [], 0, "CAN_COLLIDE"];
	_aigroup 		= creategroup civilian;
	_helipilot 		= _aigroup createUnit ["SurvivorW2_DZ",getPos _crashwreck,[],0,"FORM"];
	_helipilot 		setCombatMode "BLUE";
	_helipilot 		moveindriver _crashwreck;
	_helipilot 		assignAsDriver _crashwreck;
	
	uiSleep 0.5;
	
	if(PREWAYPOINTS > 0) then
	{
		for "_x" from 1 to PREWAYPOINTS do
		{
			_preWaypointPos = [SEARCH_CENTER,0,SEARCH_RADIUS,10,0,2000,0] call BIS_fnc_findSafePos;
			_wp = _aigroup addWaypoint [_preWaypointPos, 0];
			_wp setWaypointType "MOVE";
			_wp setWaypointBehaviour "CARELESS";
		};
	};
 
	_wp2 	= _aigroup addWaypoint [position _landingzone, 0];
	_wp2 	setWaypointType "MOVE";
	_wp2 	setWaypointBehaviour "CARELESS";
	_wp2 	setWaypointStatements ["true", "_crashwreck setDamage 1;"];
	
	while {_inFlight} do 
	{
		if ((_crashwreck distance _position) <= 1000 && !_isClose1) then 
		{
			if (_plane) then
			{
				_crashwreck flyInHeight 100;
				_crashwreck forceSpeed 150;
				_crashwreck setspeedmode "NORMAL";
				_exploRange = 360;
			}
			else
			{
				_crashwreck flyInHeight 100;
				_crashwreck forceSpeed 100;
				_crashwreck setspeedmode "NORMAL";
			};
			_isClose1 = true;
		};
		if ((_crashwreck distance _position) <= _exploRange && !_isClose2) then
		{
			if (_plane) then
			{
				_crashwreck 	setDamage 1;
				_vel 			= velocity _crashwreck;
				_dir 			= direction _crashwreck;
				_speed 			= 100;
				_crashwreck 	setVelocity [(_vel select 0)-(sin _dir*_speed),(_vel select 1)-(cos _dir*_speed),(_vel select 2) - 30];
			}
			else
			{
				_crashwreck 	setHit ["mala vrtule", 1];
				_ran15 			= random 15;
				_crashwreck 	setVelocity [_ran15,_ran15,-25];
				_crashwreck 	setDamage .9;
			};
			_isClose2 = true;
		};
		if (getPos _crashwreck select 2 <= 30 && !_isClose3) then
		{
		_crashwreck 	setVelocity [_ran15,_ran15,-20];
		_isClose3 = true;
		};
		if (getPos _crashwreck select 2 <= 5) then
		{
		deleteVehicle 		_helipilot;
		_crashwreck 	setDamage 1;
		_inFlight = false;
		};
		uiSleep 1;
	};
	
	if (DEBUG_MODE) then {diag_log(format["CRASHSPAWNER: %1 just crashed at %2!", _crashName, getPos _crashwreck]);};
	
	_pos 				= [getPos _crashwreck select 0, getPos _crashwreck select 1,0];
	_dir 				= getDir _crashwreck;

	deleteVehicle 		_crashwreck;
	deleteVehicle 		_landingzone;
	
	_isWater = surfaceIsWater [getPos _crashwreck select 0, getPos _crashwreck select 1];
	
	if(_isWater) then
	{
		[nil,nil,rTitleText,format["The %1 has crashed into the water, no loot can be secured",_porh], "PLAIN",10] call RE;
	}
	else
	{
		_crash = createVehicle [_crashModel, _pos, [], 0, "CAN_COLLIDE"];
		_crash setDir _dir;
		
		if (SPAWN_FIRE) then
		{
			PVDZ_obj_Fire = [_crash, 4, time, false, FADE_FIRE];
			publicVariable "PVDZ_obj_Fire";
		};
		
		_num = round(random RANDOM_LOOT) + GUARANTEED_LOOT;
		
		_itemTypes = Loot_SelectSingle(Loot_GetGroup("CrashSiteType"));
		_lootGroup = Loot_GetGroup(_itemTypes select 2);
		{
			_maxLootRadius 	= (random MAX_LOOT_RADIUS) + MIN_LOOT_RADIUS;
			_lootPos 		= [_pos, _maxLootRadius, random 360] call BIS_fnc_relPos;
			_lootPos set [2, 0];
			_lootVeh = Loot_Spawn(_x, _lootPos);
			_lootVeh setVariable ["permaLoot", true];
			_lootArray set[count _lootArray, _lootVeh];
			if (LOWER_GRASS) then {
				createVehicle ["ClutterCutter_small_2_EP1", _lootPos, [], 0, "CAN_COLLIDE"];
			};
			
		} forEach Loot_Select(_lootGroup, _num);
			
		if (DEBUG_MODE) then {diag_log(format["CRASHSPAWNER: Loot spawn at '%1' with loot group '%2'", _lootPos, (_itemTypes select 2)]);};
		
		_endTime = time - _startTime;
		_startTime = time;

		[nil,nil,rTitleText,format["The %1 has crashed, go and secure the loot!",_porh], "PLAIN",10] call RE;
		
		if (DEBUG_MODE) then {diag_log(format["CRASHSPAWNER: Crash completed! Wreck at: %2 - Runtime: %1 Seconds || Distance from calculated POC: %3 meters", round(_endTime), str(_pos), round(_position distance _crash)]);};
		
		_marker_position = [_pos,0,MARKER_RADIUS,0,1,2000,0] call BIS_fnc_findSafePos;
		
		while {!_missionEnd} do
		{
			if(SHOW_MARKER) then
			{
				_marker = createMarker [ format ["loot_event_marker_%1", _startTime], _marker_position];
				_marker setMarkerShape "ELLIPSE";
				_marker setMarkerColor "ColorYellow";
				_marker setMarkerAlpha 0.5;
				_marker setMarkerSize [(MARKER_RADIUS + 50), (MARKER_RADIUS + 50)];
				_marker setMarkerText _crashName;
				
				if(MARKER_NAME) then
				{
					_mdot 	= createMarker [format ["dot_%1", _startTime], _marker_position];
					_mdot 	setMarkerColor "ColorBlack";
					_mdot 	setMarkerType "mil_dot";
					_mdot 	setMarkerText _crashName;
					
				};
				uiSleep 3; deleteMarker _marker; if(MARKER_NAME) then {deleteMarker _mdot;};
			};
			
			if ((time - _startTime) >= CRASH_TIMEOUT) then
			{
				deleteVehicle _crash;
				{deleteVehicle _x;} forEach _lootArray;
				{deleteVehicle _x;} forEach nearestObjects [_pos, ["CraterLong"], 15];
				[nil,nil,rTitleText,format["Survivors did not secure the %1 crash site!",_crashName], "PLAIN",10] call RE;
				if (DEBUG_MODE) then {diag_log(format["CRASHSPAWNER: The %1 Crash timed out, removing the marker and mission objects",_crashName]);};
				_missionEnd = true;
			};
			
			{
				if((isPlayer _x) && (_x distance _pos <= 25)) then
				{
					_finder = name _x;
					[nil,nil,rTitleText,format["Survivors have secured the crash site!"], "PLAIN",10] call RE;
					if (DEBUG_MODE) then {diag_log(format["CRASHSPAWNER: Crash found by %1, removing the marker" , _finder]);};
					_missionEnd = true;
				};
			} forEach playableUnits;
			if(!SHOW_MARKER) then {uiSleep 3;};
		};
	};
};

deleteGroup _aigroup;