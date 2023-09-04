extends Node

enum traps {
	ARROW_CEILING_TRAP,
}

const trap_dict = {
	traps.ARROW_CEILING_TRAP: preload("res://scenes/ceiling_trap.tscn")
}

func get_trap_scene(trap_id: traps):
	return trap_dict[trap_id]
