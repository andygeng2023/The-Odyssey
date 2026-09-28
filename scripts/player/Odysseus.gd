class_name Odysseus
extends CharacterBody3D

@onready var inventory: OdysseyInventory = $Inventory
@onready var traversal: OdysseyTraversalSystem = $Traversal
@onready var camera: OdysseyAdventureCamera = $"../CameraRig"
@onready var survival: OdysseySurvivalSystem = $"../Systems/Survival"
@onready var weather: OdysseyWeatherSystem = $"../Systems/Weather"

const SAFE_SPAWN := Vector3(0.0, 0.88, 5.0)
const FALL_LIMIT := -12.0
const WORLD_LIMIT := 75.0
const GROUND_ACCEL := 24.0
const GROUND_DECEL := 30.0
const AIR_ACCEL := 10.0
const AIR_DECEL := 6.0
const GRAVITY := 22.0
const SWIM_SPEED := 3.4
const SWIM_SPRINT_SPEED := 4.8
const SURFACE_HEIGHT := -0.04
const FLOAT_HEIGHT := 0.62
const UNDERWATER_DEPTH := 0.45
const WATER_ENTRY_DEPTH := 0.55

var climbing := false
var swimming := false
var underwater := false
var water_volume: OdysseyWaterVolume
var speed := 4.6
var sprint_speed := 6.6
var jump_velocity := 7.2
var mobile_controls: OdysseyMobileControls
var mobile_sprint := false
var mobile_jump_requested := false
var mobile_jump_buffer := 0.0
var ground_speed := 0.0
var _recovering := false
var _visual_time := 0.0
var _visual_base_y := 0.0
var _last_ground_y := 0.88

func _ready() -> void:
    add_to_group("odyssey_player")
    floor_snap_length = 0.28
    floor_stop_on_slope = true
    floor_max_angle = deg_to_rad(48.0)
    safe_margin = 0.04
    up_direction = Vector3.UP
    _visual_base_y = $Body.position.y
    water_volume = get_tree().get_first_node_in_group("water_volume") as OdysseyWaterVolume
    mobile_controls = get_node_or_null("../UI/MobileLayer/MobileControls") as OdysseyMobileControls
    if mobile_controls:
        mobile_controls.interact_pressed.connect(try_interact)
        mobile_controls.action_pressed.connect(_on_mobile_action)

func _physics_process(delta: float) -> void:
    _recover_if_out_of_bounds()
    mobile_jump_buffer = maxf(0.0, mobile_jump_buffer - delta)

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

    var in_water_volume := water_volume != null and water_volume.contains(global_position)
    var water_depth := water_volume.depth_at(global_position) if water_volume else 0.0
    swimming = in_water_volume and water_depth >= WATER_ENTRY_DEPTH
    underwater = swimming and water_volume.is_underwater(global_position)
    climbing = is_on_wall() and not is_on_floor() and not swimming and world_direction.length_squared() > 0.05 and traversal.can_continue_traversal()

    var sprinting := Input.is_action_pressed("sprint") or mobile_sprint
    var current_speed := sprint_speed if sprinting else speed
    current_speed *= weather.movement_multiplier() if weather else 1.0

    if swimming:
        _physics_swimming(delta, world_direction, sprinting)
    else:
        _physics_ground(delta, world_direction, current_speed)

    traversal.tick(delta, climbing, swimming)
    if survival:
        survival.set_weather(weather.condition_name() if weather else "clear")
        survival.tick(delta, world_direction.length_squared() > 0.001, false, swimming, underwater)
    if traversal.stamina <= 0.0:
        climbing = false

    _animate_character(delta, world_direction.length_squared() > 0.001)
    if world_direction.length_squared() > 0.001:
        rotation.y = lerp_angle(rotation.y, atan2(-world_direction.x, -world_direction.z), delta * 9.0)

func _physics_ground(delta: float, world_direction: Vector3, current_speed: float) -> void:
    var target_horizontal := world_direction * current_speed
    var horizontal := Vector3(velocity.x, 0.0, velocity.z)
    var accel := GROUND_ACCEL if is_on_floor() else AIR_ACCEL
    var decel := GROUND_DECEL if is_on_floor() else AIR_DECEL
    if target_horizontal.length_squared() > 0.001:
        horizontal = horizontal.move_toward(target_horizontal, accel * delta)
    else:
        horizontal = horizontal.move_toward(Vector3.ZERO, decel * delta)
    velocity.x = horizontal.x
    velocity.z = horizontal.z
    ground_speed = horizontal.length()

    if not is_on_floor():
        velocity.y -= GRAVITY * delta
    elif Input.is_action_just_pressed("jump") or mobile_jump_requested:
        velocity.y = jump_velocity
        mobile_jump_requested = false
        mobile_jump_buffer = 0.0
    else:
        velocity.y = -0.35

    if climbing:
        velocity.y = 2.2
    move_and_slide()

    if is_on_floor():
        _last_ground_y = global_position.y
        apply_floor_snap()
    else:
        var steep_surface := _find_steep_surface()
        if steep_surface and world_direction.length_squared() > 0.01 and traversal.can_continue_traversal():
            climbing = true

func _physics_swimming(delta: float, world_direction: Vector3, sprinting: bool) -> void:
    var target_speed := SWIM_SPRINT_SPEED if sprinting else SWIM_SPEED
    var target := world_direction * target_speed
    var horizontal := Vector3(velocity.x, 0.0, velocity.z)
    horizontal = horizontal.move_toward(target, 10.0 * delta)
    velocity.x = horizontal.x
    velocity.z = horizontal.z

    var surface_y := water_volume.surface_height if water_volume else SURFACE_HEIGHT
    var desired_y := surface_y - FLOAT_HEIGHT
    if underwater:
        if Input.is_action_pressed("move_forward") and not mobile_controls:
            velocity.y = move_toward(velocity.y, -1.2, 5.0 * delta)
        else:
            velocity.y = move_toward(velocity.y, 0.0, 7.0 * delta)
        if Input.is_action_just_pressed("jump") or mobile_jump_requested:
            velocity.y = 3.6
            mobile_jump_requested = false
            mobile_jump_buffer = 0.0
        if global_position.y < -7.0:
            velocity.y = maxf(velocity.y, 1.4)
    else:
        velocity.y = move_toward(velocity.y, (desired_y - global_position.y) * 6.0, 12.0 * delta)
        if Input.is_action_just_pressed("jump") or mobile_jump_requested:
            velocity.y = 3.8
            mobile_jump_requested = false
            mobile_jump_buffer = 0.0

    move_and_slide()

    if not underwater and global_position.y < desired_y - 0.25:
        global_position.y = desired_y
        velocity.y = 0.0

func _find_steep_surface() -> bool:
    for i in get_slide_collision_count():
        var collision := get_slide_collision(i)
        var normal := collision.get_normal()
        var angle := rad_to_deg(acos(clampf(normal.dot(Vector3.UP), -1.0, 1.0)))
        if angle > 48.0 and angle < 88.0:
            return true
    return false

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
    var bob: float = abs(stride) * 0.035 if moving else sin(_visual_time * 2.2) * 0.012
    body.position.y = _visual_base_y + bob
    head.position.y = 1.64 + bob * 0.7
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
        underwater = false
        await get_tree().physics_frame
        _recovering = false
        var hud := get_node_or_null("../UI/GameHUD") as OdysseyGameHUD
        if hud:
            hud.show_message("Returned to the last safe shore.", 2.5)

func show_boat_message(text: String) -> void:
    var hud := get_node_or_null("../UI/GameHUD") as OdysseyGameHUD
    if hud:
        hud.show_message(text, 3.0)

func handle_mobile_action(action: String) -> void:
    match action:
        "jump":
            mobile_jump_requested = true
            mobile_jump_buffer = 0.28
        "action":
            if swimming:
                velocity.y = -2.8
        "sprint":
            mobile_sprint = not mobile_sprint

func _on_mobile_action(action: String) -> void:
    handle_mobile_action(action)

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
