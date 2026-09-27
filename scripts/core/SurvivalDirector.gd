class_name OdysseySurvivalDirector
extends Node

func _process(delta: float) -> void:
    var root := get_parent()
    var player := root.get_parent().get_node_or_null("Player") as Odysseus
    var survival := root.get_node_or_null("Survival") as OdysseySurvivalSystem
    var weather := root.get_node_or_null("Weather") as OdysseyWeatherSystem
    var fire := root.get_node_or_null("Fire") as OdysseyFireSystem
    if player == null or survival == null or weather == null or fire == null:
        return
    var near_fire := false
    for source in fire.burning.keys():
        if is_instance_valid(source) and player.global_position.distance_to(source.global_position) < 5.0:
            near_fire = true
            break
    survival.weather = weather.sea_state
    survival.tick(delta, player.velocity.length() > 0.5, near_fire)
    fire.tick(delta)
