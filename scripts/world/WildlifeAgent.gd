class_name OdysseyWildlifeAgent
extends Node3D

@export var roam_radius := 7.0
@export var speed := 0.8
@export var flee_radius := 5.5
var origin := Vector3.ZERO
var target := Vector3.ZERO
var rng := RandomNumberGenerator.new()
var player: Node3D

func _ready() -> void:
    origin = global_position
    rng.randomize()
    player = get_tree().get_first_node_in_group("odyssey_player") as Node3D
    _choose_target()

func _process(delta: float) -> void:
    if not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("odyssey_player") as Node3D
    var direction := target - global_position
    direction.y = 0.0
    if player and player.global_position.distance_to(global_position) < flee_radius:
        direction = global_position - player.global_position
        direction.y = 0.0
        speed = 2.4
    else:
        speed = 0.8
    if direction.length() < 0.4:
        _choose_target()
        return
    global_position += direction.normalized() * speed * delta
    rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 4.0)

func _choose_target() -> void:
    target = origin + Vector3(rng.randf_range(-roam_radius, roam_radius), 0, rng.randf_range(-roam_radius, roam_radius))
