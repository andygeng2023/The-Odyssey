class_name OdysseyDestructionSystem
extends Node

signal damaged(target, amount)
signal destroyed(target)

func damage(target: OdysseyWorldObject, amount: float) -> bool:
	if target == null or not target.breakable:
		return false
	var was_destroyed := target.apply_damage(amount)
	damaged.emit(target, amount)
	if was_destroyed:
		destroyed.emit(target)
	return was_destroyed

func cut_tree(target: OdysseyWorldObject, tool_power := 25.0) -> bool:
	return damage(target, tool_power)
