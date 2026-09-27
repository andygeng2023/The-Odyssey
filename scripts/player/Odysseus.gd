class_name Odysseus
extends CharacterBody3D

@onready var inventory: OdysseyInventory = $Inventory
@onready var traversal: OdysseyTraversalSystem = $Traversal

var climbing := false
var swimming := false
var last_direction := Vector3(0, 0, -1)
var gravity := 18.0
var speed := 5.0
var sprint_speed := 8.0

func _physics_process(delta: float) -> void:
    var direction := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var world_direction := Vector3(direction.x, 0.0, direction.y)
    if world_direction.length_squared() > 0.0:
        world_direction = world_direction.normalized()
        last_direction = world_direction
    var current_speed := sprint_speed if Input.is_action_pressed("sprint") else speed
    velocity.x = world_direction.x * current_speed
    velocity.z = world_direction.z * current_speed
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = 0.0
    move_and_slide()
    traversal.tick(delta, climbing, swimming)
    if traversal.stamina <= 0.0:
        climbing = false
    if world_direction.length_squared() > 0.0:
        rotation.y = lerp_angle(rotation.y, atan2(-world_direction.x, -world_direction.z), delta * 8.0)

func try_interact() -> bool:
    var nearest: OdysseyPrototypeInteractable = null
    var nearest_distance := 2.8
    for node in get_tree().get_nodes_in_group("odyssey_interactable"):
        if not is_instance_valid(node):
            continue
        var distance := global_position.distance_to(node.global_position)
        if distance <= nearest_distance:
            nearest = node
            nearest_distance = distance
    if nearest:
        nearest.interact(self)
        return true
    return false
