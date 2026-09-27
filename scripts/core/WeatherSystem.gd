class_name OdysseyWeatherSystem
extends Node
signal condition_changed(condition)
enum Condition { SUNNY, RAIN, FOG, WIND, STORM, SNOW }
var current: Condition = Condition.SUNNY
var sea_state := "calm"
func set_condition(next: Condition) -> void:
	current = next
	sea_state = "turbulent" if current == Condition.STORM else ("waves" if current == Condition.WIND else "calm")
	condition_changed.emit(current)
