class_name Odysseus
extends CharacterBody3D
@export var speed := 5.0
@export var sprint_speed := 8.0
@onready var inventory: OdysseyInventory = $Inventory
@onready var traversal: OdysseyTraversalSystem = $Traversal
var climbing := false
var swimming := false
func _physics_process(delta: float) -> void:
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := Vector3(input.x, 0.0, input.y)
	var current_speed := sprint_speed if Input.is_action_pressed("sprint") else speed
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed
	if not is_on_floor(): velocity.y -= 18.0 * delta
	move_and_slide()
	traversal.tick(delta, climbing, swimming)
	if traversal.stamina <= 0.0: climbing = false
