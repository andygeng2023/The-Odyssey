class_name OdysseyTraversalSystem
extends Node
signal stamina_changed(value)
@export var max_stamina := 100.0
@export var climb_drain := 24.0
@export var swim_drain := 10.0
@export var regen := 18.0
var stamina := max_stamina
func tick(delta: float, climbing: bool, swimming: bool) -> void:
	var drain := 0.0
	if climbing: drain += climb_drain
	if swimming: drain += swim_drain
	if drain > 0.0: stamina = max(0.0, stamina - drain * delta)
	else: stamina = min(max_stamina, stamina + regen * delta)
	stamina_changed.emit(stamina)
func can_continue_traversal() -> bool:
	return stamina > 0.0
