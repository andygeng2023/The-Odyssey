class_name OdysseyWeatherSystem
extends Node

signal condition_changed(condition)

enum Condition { SUNNY, RAIN, FOG, WIND, STORM, SNOW }
var current: Condition = Condition.SUNNY
var sea_state := "calm"
var elapsed := 0.0
var cycle_duration := 55.0

func _process(delta: float) -> void:
    elapsed += delta
    if elapsed >= cycle_duration:
        elapsed = 0.0
        var next := (int(current) + 1) % Condition.size()
        set_condition(next)

func set_condition(next: Condition) -> void:
    current = next
    sea_state = "turbulent" if current == Condition.STORM else ("waves" if current == Condition.WIND or current == Condition.RAIN else "calm")
    condition_changed.emit(current)

func condition_name() -> String:
    return Condition.keys()[current].to_lower()

func movement_multiplier() -> float:
    if current == Condition.STORM:
        return 0.82
    if current == Condition.RAIN or current == Condition.WIND:
        return 0.92
    return 1.0
