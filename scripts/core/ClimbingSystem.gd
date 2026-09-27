class_name OdysseyClimbingSystem
extends Node

signal state_changed(active)

@export var max_surface_angle := 65.0
@export var min_grip := 0.2
var active := false
var grip := 1.0

func evaluate_surface(normal: Vector3, climbable: bool) -> bool:
	if not climbable:
		return false
	var angle := rad_to_deg(acos(clamp(normal.dot(Vector3.UP), -1.0, 1.0)))
	return angle >= 90.0 - max_surface_angle and angle <= 90.0 + max_surface_angle

func begin(surface_grip := 1.0) -> bool:
	if surface_grip < min_grip:
		return false
	grip = surface_grip
	active = true
	state_changed.emit(true)
	return true

func stop() -> void:
	if not active:
		return
	active = false
	state_changed.emit(false)
