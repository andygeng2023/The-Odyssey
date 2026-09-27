class_name OdysseySwimmingSystem
extends Node

signal entered_water
signal exited_water
var in_water := false
var diving := false
var depth := 0.0

func enter() -> void:
	if in_water: return
	in_water = true
	entered_water.emit()

func exit() -> void:
	if not in_water: return
	in_water = false
	diving = false
	depth = 0.0
	exited_water.emit()

func set_dive(value: bool) -> void:
	diving = value and in_water
