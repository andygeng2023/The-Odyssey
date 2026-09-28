class_name Odysseus
extends CharacterBody3D

@onready var inventory: OdysseyInventory = $Inventory
@onready var traversal: OdysseyTraversalSystem = $Traversal
@onready var camera: OdysseyAdventureCamera = $"../CameraRig"

const SAFE_SPAWN := Vector3(0.0, 0.80, 5.0)
const FALL_LIMIT := -7.0
const WORLD_LIMIT := 75.0

var climbing := false
var swimming := false
var gravity := 18.0
var speed := 4.5
var sprint_speed := 6.4
var jump_velocity := 7.0
var mobile_controls: OdysseyMobileControls
var mobile_sprint := false
var _recovering := false
var _visual_time := 0.0
var _visual_base_y := 0.0

func _ready() -> void:
    floor_snap_length = 0.55
    _visual_base_y = $Body.position.y
    floor_stop_on_slope = true
    floor_max_angle = deg_to_rad(48.0)
    safe_margin = 0.08
    up_direction = Vector3.UP
    mobile_controls = get_node_or_null("../UI/MobileLayer/MobileControls") as OdysseyMobileControls
    if mobile_controls:
        mobile_controls.interact_pressed.connect(try_interact)
        mobile_controls.action_pressed.connect(_on_mobile_action)

func _physics_process(delta: float) -> void:
    _recover_if_out_of_bounds()

    var input_direction := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    if mobile_controls and mobile_controls.move_vector.length_squared() > 0.01:
        input_direction = mobile_controls.move_vector

    var forward := -camera.global_transform.basis.z
    forward.y = 0.0
    forward = forward.normalized()
    var right := camera.global_transform.basis.x
    right.y = 0.0
    right = right.normalized()
    var world_direction := (right * input_direction.x + forward * input_direction.y).normalized() if input_direction.length_squared() > 0.0 else Vector3.ZERO

    swimming = global_position.z < -17.0
    climbing = is_on_wall() and not is_on_floor() and not swimming and global_position.y > 0.85 and world_direction.length_squared() > 0.05

    var sprinting := Input.is_action_pressed("sprint") or mobile_sprint
    var current_speed := sprint_speed if sprinting else speed
    velocity.x = world_direction.x * current_speed
    velocity.z = world_direction.z * current_speed

    if swimming:
        velocity.y = move_toward(velocity.y, 0.0, delta * 9.0)
        if global_position.y < 0.45:
            velocity.y += 2.2 * delta
    elif climbing and traversal.can_continue_traversal():
        velocity.y = 2.6
    elif not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity
    else:
        velocity.y = 0.0

    move_and_slide()

    if not swimming and is_on_floor():
        apply_floor_snap()

    traversal.tick(delta, climbing, swimming)
    if traversal.stamina <= 0.0:
        climbing = false

    _animate_character(delta, world_direction.length_squared() > 0.001)
    if world_direction.length_squared() > 0.001:
        rotation.y = lerp_angle(rotation.y, atan2(-world_direction.x, -world_direction.z), delta * 8.0)

func _animate_character(delta: float, moving: bool) -> void:
    _visual_time += delta
    var body := $Body as MeshInstance3D
    var head := $Head as MeshInstance3D
    var cloak := $Cloak as MeshInstance3D
    var left_arm := $LeftArm as MeshInstance3D
    var right_arm := $RightArm as MeshInstance3D
    var left_leg := $LeftLeg as MeshInstance3D
    var right_leg := $RightLeg as MeshInstance3D
    if body == null or head == null:
        return
    var stride: float = sin(_visual_time * 9.0) if moving else sin(_visual_time * 2.2) * 0.12
    var bob: float = abs(stride) * 0.045 if moving else sin(_visual_time * 2.2) * 0.018
    body.position.y = _visual_base_y + bob
    head.position.y = 1.78 + bob * 0.7
    if cloak:
        cloak.rotation_degrees.z = sin(_visual_time * 5.0) * (2.5 if moving else 0.8)
    if moving:
        left_arm.rotation_degrees.z = 10.0 + stride * 12.0
        right_arm.rotation_degrees.z = -10.0 - stride * 12.0
        left_leg.rotation_degrees.x = stride * 12.0
        right_leg.rotation_degrees.x = -stride * 12.0
    else:
        left_arm.rotation_degrees.z = lerpf(left_arm.rotation_degrees.z, 10.0, delta * 5.0)
        right_arm.rotation_degrees.z = lerpf(right_arm.rotation_degrees.z, -10.0, delta * 5.0)
        left_leg.rotation_degrees.x = lerpf(left_leg.rotation_degrees.x, 0.0, delta * 5.0)
        right_leg.rotation_degrees.x = lerpf(right_leg.rotation_degrees.x, 0.0, delta * 5.0)

func _recover_if_out_of_bounds() -> void:
    if _recovering:
        return
    if global_position.y < FALL_LIMIT or absf(global_position.x) > WORLD_LIMIT or absf(global_position.z) > WORLD_LIMIT:
        _recovering = true
        velocity = Vector3.ZERO
        global_position = SAFE_SPAWN
        climbing = false
        swimming = false
        await get_tree().physics_frame
        _recovering = false
        var hud := get_node_or_null("../UI/GameHUD") as OdysseyGameHUD
        if hud:
            hud.show_message("You reached the edge of the world. Returned to solid ground.", 2.5)

func _on_mobile_action(action: String) -> void:
    match action:
        "jump":
            if swimming:
                velocity.y = 4.0
            elif is_on_floor():
                velocity.y = jump_velocity
        "sprint":
            mobile_sprint = not mobile_sprint

func try_interact() -> bool:
    var nearest: OdysseyPrototypeInteractable = null
    var nearest_distance: float = 3.8
    for node in get_tree().get_nodes_in_group("odyssey_interactable"):
        if not is_instance_valid(node):
            continue
        var distance: float = global_position.distance_to(node.global_position)
        if distance <= nearest_distance:
            nearest = node
            nearest_distance = distance
    if nearest:
        nearest.interact(self)
        return true
    return false
