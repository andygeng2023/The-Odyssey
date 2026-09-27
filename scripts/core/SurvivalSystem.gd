class_name OdysseySurvivalSystem
extends Node

signal state_changed(state)

var hunger := 100.0
var warmth := 100.0
var fatigue := 0.0
var exposure := 0.0
var weather := "clear"

func tick(delta: float, moving: bool, near_fire: bool) -> void:
    hunger = max(0.0, hunger - delta * 0.25)
    fatigue = min(100.0, fatigue + delta * (0.35 if moving else 0.12))
    warmth = min(100.0, warmth + delta * 2.0 if near_fire else warmth - delta * (0.08 if weather == "clear" else 0.25))
    exposure = clamp(100.0 - warmth, 0.0, 100.0)
    state_changed.emit(self)

func eat(amount: float = 20.0) -> void:
    hunger = min(100.0, hunger + amount)
    fatigue = max(0.0, fatigue - amount * 0.15)
    state_changed.emit(self)

func rest(amount: float = 25.0) -> void:
    fatigue = max(0.0, fatigue - amount)
    warmth = min(100.0, warmth + amount * 0.2)
    state_changed.emit(self)
