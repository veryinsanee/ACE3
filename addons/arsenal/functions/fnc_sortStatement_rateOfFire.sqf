#include "script_component.hpp"
/*
 * Author: Alganthe, SynixeBrett
 * Statement to sort weapons by their rate of fire.
 *
 * Arguments:
 * 0: Item Config <CONFIG>
 *
 * Return Value:
 * Sorting Value <NUMBER>
 *
 * Public: No
*/

params ["_config"];

private _fireModes = getArray (_config >> "modes");
private _fireRate = [];

{
    _fireRate pushBackUnique getNumber (_config >> _x >> "reloadTime");
} foreach _fireModes;

_fireRate sort true;

round (60 / (_fireRate param [0, 0]))