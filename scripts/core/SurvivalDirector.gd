class_name OdysseySurvivalDirector
extends Node

@onready var survival: OdysseySurvivalSystem = $Survival
@onready var weather: OdysseyWeatherSystem = $Weather
@onready var fire: OdysseyFireSystem = $Fire

func _process(delta: float) -> void:
    var player := get_parent().get_node_or_null("Player") as Odysseus
    if player == null:
        return
    var near_fire := false
    for source in fire.burning.keys():
        if is_instance_valid(source) and player.global_position.distance_to(source.global_position) < 5.0:
            near_fire = true
            break
    survival.weather = weather.sea_state
    survival.tick(delta, player.velocity.length() > 0.5, near_fire)
    fire.tick(delta)
