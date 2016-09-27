/*
 * Author: Glowbal, commy2
 * Handling of the open wounds & injuries upon the handleDamage eventhandler.
 *
 * Arguments:
 * 0: Unit That Was Hit <OBJECT>
 * 1: Name Of Hit Selection <STRING>
 * 2: Amount Of Damage <NUMBER>
 * 3: Shooter or source of the damage <OBJECT>
 * 4: Type of the damage done <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit", "_bodyPart", "_damage", "_typeOfProjectile", "_typeOfDamage"];
TRACE_5("start",_unit,_bodyPart,_damage,_typeOfProjectile,_typeOfDamage);

///// DELETE THIS AFTER EXTENSION HAS BEEN UPDATED
_bodyPart = EGVAR(medical,SELECTIONS) select (ALL_BODY_PARTS find _bodyPart);
/////

if (_typeOfDamage isEqualTo "") then {
    _typeOfDamage = "unknown";
};

// Administration for open wounds and ids
private _openWounds = _unit getVariable [QEGVAR(medical,openWounds), []];
private _woundID = _unit getVariable [QEGVAR(medical,lastUniqueWoundID), 1];

private _extensionOutput = "ace_medical" callExtension format ["HandleDamageWounds,%1,%2,%3,%4", _bodyPart, _damage, _typeOfDamage, _woundID];
TRACE_1("",_extensionOutput);

// these are default values and modified by _extensionOutput
private _painToAdd = 0;
private _woundsCreated = [];

call compile _extensionOutput;

{
    _x params ["", "_woundClassIDToAdd", "_bodyPartNToAdd"];

    _foundIndex = -1;
    {
        // Check if we have an id of the given class on the given bodypart already
        if ((_woundClassIDToAdd isEqualTo (_x select 1)) && {_bodyPartNToAdd isEqualTo (_x select 2)}) exitWith {
            _foundIndex = _forEachIndex;
        };
    } forEach _openWounds;

    if (_foundIndex < 0) then {
        // Since it is a new injury, we will have to add it to the open wounds array to store it
        _openWounds pushBack _x;
    } else {
        // We already have one of these, so we are just going to increase the number that we have of it with a new one.
        private _injury = _openWounds select _foundIndex;
        _injury set [3, (_injury select 3) + 1];
    };
} forEach _woundsCreated;

_unit setVariable [QEGVAR(medical,openWounds), _openWounds, true];

// Only update if new wounds have been created
if (count _woundsCreated > 0) then {
    _unit setVariable [QEGVAR(medical,lastUniqueWoundID), _woundID, true];
};

// TODO use medical add pain function instead
private _painLevel = _unit getVariable [QEGVAR(medical,pain), 0];
_unit setVariable [QEGVAR(medical,pain), _painLevel + _painToAdd];

TRACE_6("exit",_unit, _painLevel, _painToAdd, _unit getVariable QEGVAR(medical,pain), _unit getVariable QEGVAR(medical,openWounds),_woundsCreated);