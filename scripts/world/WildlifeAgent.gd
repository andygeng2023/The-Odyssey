class_name OdysseyWildlifeAgent
extends Node3D

@export var roam_radius := 5.0
@export var speed := 0.8
var origin := Vector3.ZERO
var target := Vector3.ZERO
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    origin = global_position
    rng.randomize()
    _choose_target()

func _process(delta: float) -> void:
    var direction := target - global_position
    direction.y = 0.0
    if direction.length() < 0.3:
        _choose_target()
        return
    global_position += direction.normalized() * speed * delta
    rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 3.0)

func _choose_target() -> void:
    target = origin + Vector3(rng.randf_range(-roam_radius, roam_radius), 0, rng.randf_range(-roam_radius, roam_radius))
