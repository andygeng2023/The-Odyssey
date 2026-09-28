class_name OdysseySurvivalSystem
extends Node

signal state_changed(state)

var hunger := 100.0
var warmth := 100.0
var fatigue := 0.0
var exposure := 0.0
var oxygen := 100.0
var max_health := 5.0
var health := 5.0
var weather := "clear"

func tick(delta: float, moving: bool, near_fire: bool, in_water := false, underwater := false) -> void:
    hunger = maxf(0.0, hunger - delta * 0.20)
    fatigue = minf(100.0, fatigue + delta * (0.30 if moving else 0.10))
    var cold_rate := 0.08 if weather == "clear" else 0.20
    if weather == "storm":
        cold_rate = 0.34
    warmth = clampf(warmth + (delta * 2.4 if near_fire else -delta * cold_rate), 0.0, 100.0)
    exposure = clampf(100.0 - warmth, 0.0, 100.0)
    if underwater:
        oxygen = maxf(0.0, oxygen - delta * 8.0)
    else:
        oxygen = minf(100.0, oxygen + delta * 18.0)
    if in_water and not underwater:
        fatigue = minf(100.0, fatigue + delta * 0.05)
    state_changed.emit(self)

func set_weather(value: String) -> void:
    weather = value
    state_changed.emit(self)

func eat(amount: float = 20.0) -> void:
    hunger = minf(100.0, hunger + amount)
    fatigue = maxf(0.0, fatigue - amount * 0.12)
    state_changed.emit(self)

func rest(amount: float = 25.0) -> void:
    fatigue = maxf(0.0, fatigue - amount)
    warmth = minf(100.0, warmth + amount * 0.2)
    state_changed.emit(self)

func damage(amount: float) -> void:
    health = clampf(health - maxf(0.0, amount), 0.0, max_health)
    state_changed.emit(self)

func heal(amount: float) -> void:
    health = clampf(health + maxf(0.0, amount), 0.0, max_health)
    state_changed.emit(self)
