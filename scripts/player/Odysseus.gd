class_name Odysseus
extends CharacterBody3D

@onready var inventory: OdysseyInventory = $Inventory
@onready var traversal: OdysseyTraversalSystem = $Traversal
@onready var camera: OdysseyAdventureCamera = $CameraRig

var climbing := false
var swimming := false
var gravity := 18.0
var speed := 4.8
var sprint_speed := 7.0
var jump_velocity := 7.0
var mobile_controls: OdysseyMobileControls

func _ready() -> void:
    mobile_controls = get_node_or_null("../UI/MobileControls") as OdysseyMobileControls
    if mobile_controls:
        mobile_controls.interact_pressed.connect(try_interact)
        mobile_controls.action_pressed.connect(_on_mobile_action)

func _physics_process(delta: float) -> void:
    var direction := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    if mobile_controls and mobile_controls.move_vector.length_squared() > 0.01:
        direction = mobile_controls.move_vector
    var forward := -camera.global_transform.basis.z
    forward.y = 0.0
    forward = forward.normalized()
    var right := camera.global_transform.basis.x
    right.y = 0.0
    right = right.normalized()
    var world_direction := (right * direction.x + forward * direction.y)
    if world_direction.length_squared() > 0.0:
        world_direction = world_direction.normalized()
    var current_speed := sprint_speed if Input.is_action_pressed("sprint") else speed
    velocity.x = world_direction.x * current_speed
    velocity.z = world_direction.z * current_speed
    if not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity
    move_and_slide()
    traversal.tick(delta, false, swimming)

    if world_direction.length_squared() > 0.0:
        rotation.y = lerp_angle(rotation.y, atan2(-world_direction.x, -world_direction.z), delta * 9.0)

func _on_mobile_action(action: String) -> void:
    if action == "jump" and is_on_floor():
        velocity.y = jump_velocity
    elif action == "interact":
        try_interact()
    elif action == "action":
        try_interact()

func try_interact() -> bool:
    var nearest: OdysseyPrototypeInteractable = null
    var nearest_distance := 3.2
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
