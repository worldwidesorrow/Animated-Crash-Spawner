/*
	Script Name: animated_crash_spawner.sqf
	Original Author: Grafzahl / Finest
	Modified by BushWookie & Forgotten for Epoch
	Modified by f3cuk for Epoch 1051
	Modified by JasonTM for Epoch 1062
	Script Version: 1.3.3
	Last update: 11-15-2018
*/

private["_lootArray","_lootVeh","_finder","_crash","_preWaypointPos","_endTime","_time","_heliStart","_lootPos","_wp2","_landingzone","_aigroup","_wp","_pilot","_crashwreck","_pos","_dir","_mdot","_pos","_num","_marker","_itemTypes"];

#include "\z\addons\dayz_code\loot\Loot.hpp"

// Configs - You can adjust these
#define DEBUG_MODE false // Adds diagnostic entries to the server rpt
#define CRASH_TIMEOUT 300 // The amount of time it takes for the mission to time out if no players show up
#define GUARANTEED_LOOT	16 // Guaranteed Loot Spawns
#define RANDOM_LOOT	8 // Random number of loot piles as well as the guaranteed ones
#define SPAWN_FIRE true // Spawn Smoke/Fire at the helicrash
#define FADE_FIRE false	// Fade the Smoke/Fire overtime
#define PREWAYPOINTS 2 // Amount of way points the heli flies to before crashing
#define MIN_LOOT_RADIUS 4 // Minimum distance for loot to spawn from the crash site in meters
#define MAX_LOOT_RADIUS 10 // Maximum distance for loot to spawn from the crash site in meters
#define MARKER_RADIUS 400 // Radius for the marker
#define SHOW_MARKER	true // Show a marker on the map
#define MARKER_NAME true // Add the crash name to the marker, SHOW_MARKER must be true
#define LOWER_GRASS	true // lowers the grass around the loot
_crashDamage = 1; // Amount of damage the heli can take before crashing (between 0.1 and 1) Lower the number and the heli can take less damage before crashing 1 damage is fully destroyed and 0.1 something like a DMR could one shot the heli
_exploRange	= 200; // How far away from the predefined crash point should the heli start crashing
_messageType = "TitleText"; // Type of announcement message. Options "Hint","TitleText". ***Warning: Hint appears in the same screen space as common debug monitors
_startDist = 4000; // increase this to delay the time it takes for the plane to arrive at the mission
#define TITLE_COLOR "#00FF11" // Hint Option: Color of Top Line
#define TITLE_SIZE "2" // Hint Option: Size of top line
#define IMAGE_SIZE "4" // Hint Option: Size of the image
#define SEARCH_BLACKLIST [[[2092,14167],[10558,12505]]]

// Initialize mission variables - DO NOT CHANGE THESE
_ran15 = 0;
_isClose1 = false;
_isClose2 = false;
_isClose3 = false;
_inFlight = true;
_end = false;
_lootArray = [];

// Do not change below values if you do not know what you are doing
_select = [["UH1Y_DZE","UH1YWreck",false],["MV22","MV22Wreck",false],["Mi17_DZ","Mi17Wreck",false],["UH60M_EP1","MH60Wreck",false],["UH60M_MEV_EP1","MH60Wreck",false],["A10","A10Wreck",true],["Ka52Black","Ka52Wreck",false],["Mi24_D","Mi24Wreck",false],["AH1Z","AH1ZWreck",false],["AV8B","AV8BWreck",true],["Su25_TK_EP1","SU25Wreck",true]] call BIS_fnc_selectRandom;
_heliModel = _select select 0;
_crashModel	= _select select 1;
_plane = _select select 2;
_crashName = getText (configFile >> "CfgVehicles" >> _heliModel >> "displayName");
_img = (getText (configFile >> "CfgVehicles" >> _heliModel >> "picture"));

if (_messageType == "Hint") then {
	RemoteMessage = ["hintWithImage",["STR_CL_ACS_TITLE",["STR_CL_ACS_ANNOUNCE",_crashName]],[_img,TITLE_COLOR,TITLE_SIZE,IMAGE_SIZE]];
} else {
	RemoteMessage = ["titleText",["STR_CL_ACS_ANNOUNCE",_crashName]];
};
publicVariable "RemoteMessage";

_pos = [getMarkerPos "crashsites", 0, (getMarkerSize "crashsites") select 0, 20, 0, .3, 0, SEARCH_BLACKLIST] call BIS_fnc_findSafePos;
_pos set [2, 0];

_PorM = if (random 1 > .5) then {"+"} else {"-"};
_PorM2 = if (random 1 > .5) then {"+"} else {"-"};
_heliStart = call compile format ["[(%1 select 0) %2 %4,(%1 select 1) %3 %4, 400]",_pos,_PorM,_PorM2,_startDist];

if (DEBUG_MODE) then {diag_log format["CRASHSPAWNER: %1 started flying from %2 to %3 NOW!(TIME:%4)", _crashName,_heliStart,_pos,round(time)];};

_time = time;
_crashwreck = createVehicle [_heliModel,_heliStart, [], 0, "FLY"];
dayz_serverObjectMonitor set [count dayz_serverObjectMonitor,_crashwreck];
_crashwreck engineOn true;
_crashwreck flyInHeight 150;

if (_plane) then {
	_crashDamage = .5;
	_crashwreck setDamage .4;
	_crashwreck forceSpeed 250;
	_crashwreck setSpeedMode "LIMITED";
} else {
	_crashwreck forceSpeed 150;
	_crashwreck setSpeedMode "NORMAL";
};

_landingzone = "HeliHEmpty" createVehicle [0,0,0];
_landingzone setPos _pos;
_aigroup = createGroup civilian;
_pilot = _aigroup createUnit ["SurvivorW2_DZ",getPos _crashwreck,[],0,"FORM"];
_pilot setCombatMode "BLUE";
_pilot moveInDriver _crashwreck;
_pilot assignAsDriver _crashwreck;

uiSleep 0.5;

if(PREWAYPOINTS > 0) then
{
	for "_x" from 1 to PREWAYPOINTS do
	{
		_preWaypointPos = [getMarkerPos "crashsites",0,(getMarkerSize "crashsites") select 0,10,0,2000,0] call BIS_fnc_findSafePos;
		_wp = _aigroup addWaypoint [_preWaypointPos, 0];
		_wp setWaypointType "MOVE";
		_wp setWaypointBehaviour "CARELESS";
	};
};

_wp = _aigroup addWaypoint [position _landingzone, 0];
_wp setWaypointType "MOVE";
_wp setWaypointBehaviour "CARELESS";
//_wp2 setWaypointStatements ["true", "_crashwreck setDamage 1;"];

while {_inFlight} do {
	if ((_crashwreck distance _pos) <= 1000 && !_isClose1) then {
		if (_plane) then {
			_crashwreck flyInHeight 100;
			_crashwreck forceSpeed 150;
			_crashwreck setSpeedMode "NORMAL";
			_exploRange = 360;
		} else {
			_crashwreck flyInHeight 100;
			_crashwreck forceSpeed 100;
			_crashwreck setSpeedMode "NORMAL";
		};
		_isClose1 = true;
	};
	
	if ((_crashwreck distance _pos) <= _exploRange && !_isClose2) then {
		if (_plane) then {
			_crashwreck setDamage 1;
			_vel = velocity _crashwreck;
			_dir = direction _crashwreck;
			_speed = 100;
			_crashwreck setVelocity [(_vel select 0)-(sin _dir*_speed),(_vel select 1)-(cos _dir*_speed),(_vel select 2) - 30];
		} else {
			_crashwreck setHit ["mala vrtule", 1];
			_ran15 = random 15;
			_crashwreck setVelocity [_ran15,_ran15,-25];
			_crashwreck setDamage .9;
		};
		_isClose2 = true;
	};
	
	if (getPos _crashwreck select 2 <= 30 && !_isClose3) then {
		_crashwreck setVelocity [_ran15,_ran15,-20];
		_isClose3 = true;
	};
	
	if (getPos _crashwreck select 2 <= 5) then {
		deleteVehicle _pilot;
		_crashwreck setDamage 1;
		_inFlight = false;
	};
	
	uiSleep 1;
};

if (DEBUG_MODE) then {diag_log format["CRASHSPAWNER: %1 just crashed at %2!", _crashName, getPos _crashwreck];};

_pos = [getPos _crashwreck select 0, getPos _crashwreck select 1,0];
_dir = getDir _crashwreck;

deleteVehicle _crashwreck;
deleteVehicle _landingzone;

_isWater = surfaceIsWater [getPos _crashwreck select 0, getPos _crashwreck select 1];

if(_isWater) then {
	
	if (_messageType == "Hint") then {
		RemoteMessage = ["hintWithImage",["STR_CL_ACS_TITLE",["STR_CL_ACS_WATERCRASH",_crashName]],[_img,TITLE_COLOR,TITLE_SIZE,IMAGE_SIZE]];
	} else {
		RemoteMessage = ["titleText",["STR_CL_ACS_WATERCRASH",_crashName]];
	};
	publicVariable "RemoteMessage";
} else {
	
	_crash = _crashModel createVehicle [0,0,0];
	_crash setDir _dir;
	_crash setPos _pos;
	
	if (SPAWN_FIRE) then {
		PVDZ_obj_Fire = [_crash, 4, time, false, FADE_FIRE];
		publicVariable "PVDZ_obj_Fire";
	};
	
	_num = round(random RANDOM_LOOT) + GUARANTEED_LOOT;
	
	_itemTypes = Loot_SelectSingle(Loot_GetGroup("CrashSiteType"));
	_lootGroup = Loot_GetGroup(_itemTypes select 2);
	
	{
		_maxLootRadius = (random MAX_LOOT_RADIUS) + MIN_LOOT_RADIUS;
		_lootPos = [_pos, _maxLootRadius, random 360] call BIS_fnc_relPos;
		_lootPos set [2, 0];
		_lootVeh = Loot_Spawn(_x, _lootPos);
		_lootVeh setVariable ["permaLoot", true];
		_lootArray set[count _lootArray, _lootVeh];
		if (LOWER_GRASS) then {
			createVehicle ["ClutterCutter_small_2_EP1", _lootPos, [], 0, "CAN_COLLIDE"];
		};
		
	} forEach Loot_Select(_lootGroup, _num);
		
	if (DEBUG_MODE) then {diag_log(format["CRASHSPAWNER: Loot spawn at '%1' with loot group '%2'", _lootPos, (_itemTypes select 2)]);};
	
	_endTime = time - _time;
	_time = time;
	
	if (_messageType == "Hint") then {
		RemoteMessage = ["hintWithImage",["STR_CL_ACS_TITLE",["STR_CL_ACS_CRASH",_crashName]],[_img,TITLE_COLOR,TITLE_SIZE,IMAGE_SIZE]];
	} else {
		RemoteMessage = ["titleText",["STR_CL_ACS_CRASH",_crashName]];
	};
	publicVariable "RemoteMessage";
	
	if (DEBUG_MODE) then {diag_log(format["CRASHSPAWNER: Crash completed! Wreck at: %2 - Runtime: %1 Seconds || Distance from calculated POC: %3 meters", round(_endTime), str(_pos), round(_pos distance _crash)]);};
	
	_marker_pos = [_pos,0,MARKER_RADIUS,0,1,2000,0] call BIS_fnc_findSafePos;
	
	// Remove the crash craters so they don't cover up the loot.
	_craters = nearestObjects [_pos, ["CraterLong"], 20];
	
	if (count _craters > 0) then {
		{deleteVehicle _x;} count _craters;
	};
	
	while {!_end} do {
		if(SHOW_MARKER) then {
			_marker = createMarker [ format ["loot_event_marker_%1", _time], _marker_pos];
			_marker setMarkerShape "ELLIPSE";
			_marker setMarkerColor "ColorYellow";
			_marker setMarkerAlpha 0.5;
			_marker setMarkerSize [(MARKER_RADIUS + 50), (MARKER_RADIUS + 50)];
			_marker setMarkerText _crashName;
			
			if(MARKER_NAME) then {
				_mdot = createMarker [format ["dot_%1", _time], _marker_pos];
				_mdot setMarkerColor "ColorBlack";
				_mdot setMarkerType "mil_dot";
				_mdot setMarkerText format ["%1 Crashsite",_crashName];
			};
			uiSleep 3; deleteMarker _marker; if(MARKER_NAME) then {deleteMarker _mdot;};
		};
		
		if ((time - _time) >= CRASH_TIMEOUT) then {
			deleteVehicle _crash;
			{deleteVehicle _x;} count _lootArray;
			
			if (_messageType == "Hint") then {
				RemoteMessage = ["hintWithImage",["STR_CL_ACS_TITLE",["STR_CL_ACS_TIMEOUT",_crashName]],[_img,TITLE_COLOR,TITLE_SIZE,IMAGE_SIZE]];
			} else {
				RemoteMessage = ["titleText",["STR_CL_ACS_TIMEOUT",_crashName]];
			};
			publicVariable "RemoteMessage";
			
			if (DEBUG_MODE) then {diag_log(format["CRASHSPAWNER: The %1 Crash timed out, removing the marker and mission objects",_crashName]);};
			_end = true;
		};
		
		{
			if((isPlayer _x) && (_x distance _pos <= 25)) then {
				_finder = name _x;
				
				if (_messageType == "Hint") then {
					RemoteMessage = ["hintWithImage",["STR_CL_ACS_TITLE",["STR_CL_ACS_SUCCESS",_crashName]],[_img,TITLE_COLOR,TITLE_SIZE,IMAGE_SIZE]];
				} else {
					RemoteMessage = ["titleText",["STR_CL_ACS_SUCCESS",_crashName]];
				};
				publicVariable "RemoteMessage";
				
				if (DEBUG_MODE) then {diag_log(format["CRASHSPAWNER: Crash found by %1, removing the marker" , _finder]);};
				_end = true;
			};
		} forEach playableUnits;
		if(!SHOW_MARKER) then {uiSleep 3;};
	};
};

deleteGroup _aigroup;
