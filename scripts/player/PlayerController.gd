class_name OdysseyPlayerController
extends Node

@export var speed := 5.0
@export var sprint_speed := 8.0
@export var gravity := 18.0

func move_character(body: CharacterBody3D, delta: float) -> void:
    var direction := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var world_direction := Vector3(direction.x, 0.0, direction.y)
    if world_direction.length_squared() > 0.0:
        world_direction = world_direction.normalized()
    var current_speed := sprint_speed if Input.is_action_pressed("sprint") else speed
    body.velocity.x = world_direction.x * current_speed
    body.velocity.z = world_direction.z * current_speed
    if not body.is_on_floor():
        body.velocity.y -= gravity * delta
    else:
        body.velocity.y = 0.0
    body.move_and_slide()
    if world_direction.length_squared() > 0.0:
        body.rotation.y = lerp_angle(body.rotation.y, atan2(-world_direction.x, -world_direction.z), delta * 8.0)
