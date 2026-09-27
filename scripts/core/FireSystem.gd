class_name OdysseyFireSystem
extends Node

signal ignited(source)
signal extinguished(source)

var burning: Dictionary = {}
@export var spread_radius := 2.5
@export var spread_chance := 0.15

func ignite(source: Node3D) -> bool:
	if source == null or burning.has(source):
		return false
	burning[source] = 0.0
	ignited.emit(source)
	return true

func extinguish(source: Node3D) -> void:
	if not burning.has(source):
		return
	burning.erase(source)
	extinguished.emit(source)

func tick(delta: float) -> void:
	for source in burning.keys():
		if not is_instance_valid(source):
			burning.erase(source)
			continue
		burning[source] += delta
		if source.has_method("apply_fire_damage"):
			source.apply_fire_damage(delta)
