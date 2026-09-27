class_name Odysseus
extends CharacterBody3D

@export var speed := 5.0
@export var sprint_speed := 8.0
@onready var inventory: OdysseyInventory = $Inventory
@onready var traversal: OdysseyTraversalSystem = $Traversal

var climbing := false
var swimming := false
var last_direction := Vector3(0, 0, -1)
var gravity := 18.0

func _physics_process(delta: float) -> void:
	var direction := Vector3.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		direction.z -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		direction.z += 1.0

	if direction.length_squared() > 0.0:
		direction = direction.normalized()
		last_direction = direction

	var sprinting := Input.is_key_pressed(KEY_SHIFT) or Input.is_action_pressed("sprint")
	var current_speed := sprint_speed if sprinting else speed
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()
	traversal.tick(delta, climbing, swimming)

	if traversal.stamina <= 0.0:
		climbing = false

	if direction.length_squared() > 0.0:
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 8.0)

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
