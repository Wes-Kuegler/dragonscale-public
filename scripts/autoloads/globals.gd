extends Node

const SPIKE_COLLISION_LAYER_BITMASK = 32 # no idea why the spike layer gives a bitmask of 32
const PLAYER_SHIELD_LAYER_MASK = 16 # ditto
var player:Player
var ui:UI

var stage_time:float #current stage time
func format_stage_time(time:float) -> String:
	return str(snapped(time, 0.01)).pad_decimals(2)
