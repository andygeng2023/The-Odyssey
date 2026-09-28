class_name Odysseus
extends CharacterBody3D

@onready var inventory: OdysseyInventory = $Inventory
@onready var traversal: OdysseyTraversalSystem = $Traversal
@onready var camera: OdysseyAdventureCamera = $"../CameraRig"
@onready var survival: OdysseySurvivalSystem = $"../Systems/Survival"
@onready var weather: OdysseyWeatherSystem = $"../Systems/Weather"

const SAFE_SPAWN := Vector3(0.0, 0.88, 5.0)
const FALL_LIMIT := -12.0
const WORLD_LIMIT := 125.0
const GROUND_ACCEL := 24.0
const GROUND_DECEL := 30.0
const AIR_ACCEL := 10.0
const AIR_DECEL := 6.0
const GRAVITY := 22.0
const SWIM_SPEED := 3.4
const SWIM_SPRINT_SPEED := 4.8
const SURFACE_HEIGHT := -0.04
const SWIM_BODY_DEPTH := 0.42
const UNDERWATER_DEPTH := 0.85
const WATER_ENTRY_DEPTH := 0.45
const PLAYER_HALF_HEIGHT := 0.875
const STEP_HEIGHT := 0.34
const STEP_CHECK_DISTANCE := 0.32
const CLIMB_MAX_ANGLE := 78.0
const CLIMB_DETECT_DISTANCE := 1.15
const CLIMB_UP_SPEED := 2.5
const SWIM_ACCEL := 8.0
const SWIM_DRAG := 3.2
const WATER_BUOYANCY := 5.5
const WATER_SURFACE_SPRING := 9.0
const CLIMB_FOOT_HEIGHT := 0.34
const CLIMB_HAND_HEIGHT := 1.18

enum TraversalState { GROUNDED, AIRBORNE, STEP_UP, CLIMBING, SWIM_SURFACE, SWIM_UNDERWATER }

var traversal_state: TraversalState = TraversalState.GROUNDED
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
var mobile_dive_requested := false
var mobile_jump_buffer := 0.0
var ground_speed := 0.0
var _recovering := false
var _visual_time := 0.0
var _visual_base_y := 0.0
var _last_ground_y := 0.88

func _ready() -> void:
    add_to_group("odyssey_player")
    floor_snap_length = 0.42
    floor_stop_on_slope = true
    floor_constant_speed = true
    floor_max_angle = deg_to_rad(48.0)
    safe_margin = 0.035
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
    var world_direction := Vector3.ZERO
    if input_direction.length_squared() > 0.0:
        world_direction = (right * input_direction.x + forward * input_direction.y).normalized()

    var in_water_volume := water_volume != null and water_volume.contains(global_position)
    var water_depth := water_volume.depth_at(global_position) if water_volume else 0.0
    swimming = in_water_volume and water_depth >= WATER_ENTRY_DEPTH
    underwater = swimming and water_volume.is_underwater(global_position)
    climbing = not swimming and world_direction.length_squared() > 0.05 and traversal.can_continue_traversal() and _detect_auto_climb(world_direction)

    var sprinting := Input.is_action_pressed("sprint") or mobile_sprint
    var current_speed := sprint_speed if sprinting else speed
    current_speed *= weather.movement_multiplier() if weather else 1.0

    if swimming:
        _physics_swimming(delta, world_direction, sprinting)
    else:
        _physics_ground(delta, world_direction, current_speed)

    _update_traversal_state()

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

    if climbing:
        traversal_state = TraversalState.CLIMBING
        velocity.y = CLIMB_UP_SPEED
    elif not is_on_floor():
        velocity.y -= GRAVITY * delta
    elif Input.is_action_just_pressed("jump") or mobile_jump_requested:
        velocity.y = jump_velocity
        mobile_jump_requested = false
        mobile_jump_buffer = 0.0
    else:
        velocity.y = -0.45

    if is_on_floor() and not climbing and horizontal.length_squared() > 0.01:
        if _attempt_step_up(horizontal * delta):
            traversal_state = TraversalState.STEP_UP

    move_and_slide()

    if is_on_floor():
        _last_ground_y = global_position.y
        apply_floor_snap()

    if not climbing and world_direction.length_squared() > 0.01 and traversal.can_continue_traversal() and _should_start_climbing(world_direction):
        climbing = true
        traversal_state = TraversalState.CLIMBING
    elif not climbing:
        traversal_state = TraversalState.GROUNDED if is_on_floor() else TraversalState.AIRBORNE

func _physics_swimming(delta: float, world_direction: Vector3, sprinting: bool) -> void:
    traversal_state = TraversalState.SWIM_UNDERWATER if underwater else TraversalState.SWIM_SURFACE
    var target_speed := SWIM_SPRINT_SPEED if sprinting else SWIM_SPEED
    var target := world_direction * target_speed
    var horizontal := Vector3(velocity.x, 0.0, velocity.z)
    if target.length_squared() > 0.001:
        horizontal = horizontal.move_toward(target, SWIM_ACCEL * delta)
    else:
        horizontal = horizontal.move_toward(Vector3.ZERO, SWIM_DRAG * delta)
    velocity.x = horizontal.x
    velocity.z = horizontal.z

    var surface_y := water_volume.surface_height if water_volume else SURFACE_HEIGHT
    var surface_body_y := surface_y - SWIM_BODY_DEPTH

    if underwater:
        var vertical_target := 0.0
        if Input.is_action_pressed("move_back"):
            vertical_target += 0.9
        if Input.is_action_pressed("jump") or mobile_jump_requested:
            vertical_target += 3.6
        if mobile_dive_requested or Input.is_action_pressed("action"):
            vertical_target -= 3.2

        var depth_target := surface_body_y - UNDERWATER_DEPTH
        var buoyancy := clampf((depth_target - global_position.y) * WATER_BUOYANCY, -4.0, 4.0)
        velocity.y = move_toward(velocity.y, vertical_target + buoyancy, 8.0 * delta)
        velocity.y = move_toward(velocity.y, 0.0, 1.2 * delta)
        mobile_jump_requested = false
        mobile_dive_requested = false

        if global_position.y < water_volume.bottom_height + 0.8:
            velocity.y = maxf(velocity.y, 2.0)
    else:
        var surface_error := surface_body_y - global_position.y
        velocity.y = move_toward(velocity.y, surface_error * WATER_SURFACE_SPRING, 12.0 * delta)
        if Input.is_action_just_pressed("jump") or mobile_jump_requested:
            velocity.y = 3.8
            mobile_jump_requested = false
            mobile_jump_buffer = 0.0
        if mobile_dive_requested or Input.is_action_just_pressed("action"):
            velocity.y = -3.0
            mobile_dive_requested = false

    move_and_slide()

func _attempt_step_up(horizontal_motion: Vector3) -> bool:
    if horizontal_motion.length() > STEP_CHECK_DISTANCE:
        horizontal_motion = horizontal_motion.normalized() * STEP_CHECK_DISTANCE
    if horizontal_motion.length_squared() < 0.0001:
        return false

    var collision := KinematicCollision3D.new()
    if not test_move(global_transform, horizontal_motion, collision, 0.02, false):
        return false

    var hit_normal := collision.get_normal()
    var hit_angle := rad_to_deg(acos(clampf(hit_normal.dot(Vector3.UP), -1.0, 1.0)))
    if hit_angle < 8.0 or hit_angle > 56.0:
        return false

    var raised := global_transform
    raised.origin += Vector3.UP * STEP_HEIGHT
    if test_move(raised, horizontal_motion, null, 0.02, false):
        return false

    var landing := KinematicCollision3D.new()
    if not test_move(raised, Vector3.DOWN * (STEP_HEIGHT + 0.16), landing, 0.02, false):
        return false

    global_transform = raised
    velocity.y = 0.0
    return true

func _detect_auto_climb(world_direction: Vector3) -> bool:
    if world_direction.length_squared() < 0.01:
        return false

    var direction := world_direction.normalized()
    var space := get_world_3d().direct_space_state
    var lower_origin := global_position + Vector3.UP * CLIMB_FOOT_HEIGHT
    var upper_origin := global_position + Vector3.UP * CLIMB_HAND_HEIGHT
    var lower_to := lower_origin + direction * CLIMB_DETECT_DISTANCE
    var upper_to := upper_origin + direction * CLIMB_DETECT_DISTANCE

    var lower_query := PhysicsRayQueryParameters3D.create(lower_origin, lower_to, 1)
    lower_query.exclude = [get_rid()]
    var lower_hit := space.intersect_ray(lower_query)
    if lower_hit.is_empty():
        return false

    var normal: Vector3 = lower_hit.normal
    var angle := rad_to_deg(acos(clampf(normal.dot(Vector3.UP), -1.0, 1.0)))
    if angle <= 48.0 or angle > CLIMB_MAX_ANGLE:
        return false

    var upper_query := PhysicsRayQueryParameters3D.create(upper_origin, upper_to, 1)
    upper_query.exclude = [get_rid()]
    var upper_hit := space.intersect_ray(upper_query)
    if not upper_hit.is_empty():
        var upper_normal: Vector3 = upper_hit.normal
        var upper_angle := rad_to_deg(acos(clampf(upper_normal.dot(Vector3.UP), -1.0, 1.0)))
        if upper_angle > CLIMB_MAX_ANGLE:
            return false

    return traversal.can_continue_traversal()

func _should_start_climbing(world_direction: Vector3) -> bool:
    return _detect_auto_climb(world_direction) or _find_steep_surface()

func _update_traversal_state() -> void:
    if swimming:
        traversal_state = TraversalState.SWIM_UNDERWATER if underwater else TraversalState.SWIM_SURFACE
    elif climbing:
        traversal_state = TraversalState.CLIMBING
    elif is_on_floor():
        if traversal_state != TraversalState.STEP_UP:
            traversal_state = TraversalState.GROUNDED
    else:
        traversal_state = TraversalState.AIRBORNE

func teleport_to(destination: Vector3) -> void:
    velocity = Vector3.ZERO
    climbing = false
    swimming = false
    underwater = false
    traversal_state = TraversalState.GROUNDED
    mobile_jump_requested = false
    mobile_dive_requested = false

    var space := get_world_3d().direct_space_state
    var query := PhysicsRayQueryParameters3D.create(
        destination + Vector3.UP * 20.0,
        destination + Vector3.DOWN * 20.0,
        1
    )
    query.exclude = [get_rid()]
    var hit := space.intersect_ray(query)
    if not hit.is_empty():
        global_position = hit.position + Vector3.UP * (PLAYER_HALF_HEIGHT + 0.015)
    else:
        global_position = destination + Vector3.UP * PLAYER_HALF_HEIGHT

    apply_floor_snap()
    _last_ground_y = global_position.y
    var camera_rig := get_node_or_null("../CameraRig") as OdysseyAdventureCamera
    if camera_rig:
        camera_rig.snap_to_target()

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

    var gait := sin(_visual_time * 8.4)
    var stride: float = gait if moving else 0.0
    var bob: float = abs(gait) * 0.025 if moving else sin(_visual_time * 1.8) * 0.008
    body.position.y = _visual_base_y + bob
    head.position.y = 1.64 + bob * 0.72

    var lean := clampf(ground_speed / maxf(1.0, sprint_speed), 0.0, 1.0)
    body.rotation.z = lerpf(body.rotation.z, -0.035 * lean, delta * 10.0)
    if is_instance_valid(cloak):
        cloak.rotation_degrees.z = sin(_visual_time * 4.0) * (2.0 if moving else 0.6)
        cloak.position.y = lerpf(cloak.position.y, 0.94 + bob * 0.6, delta * 8.0)

    if moving:
        left_arm.rotation_degrees.z = lerpf(left_arm.rotation_degrees.z, 8.0 + stride * 8.0, delta * 12.0)
        right_arm.rotation_degrees.z = lerpf(right_arm.rotation_degrees.z, -8.0 - stride * 8.0, delta * 12.0)
        left_leg.rotation_degrees.x = lerpf(left_leg.rotation_degrees.x, stride * 9.0, delta * 12.0)
        right_leg.rotation_degrees.x = lerpf(right_leg.rotation_degrees.x, -stride * 9.0, delta * 12.0)
    else:
        left_arm.rotation_degrees.z = lerpf(left_arm.rotation_degrees.z, 8.0, delta * 7.0)
        right_arm.rotation_degrees.z = lerpf(right_arm.rotation_degrees.z, -8.0, delta * 7.0)
        left_leg.rotation_degrees.x = lerpf(left_leg.rotation_degrees.x, 0.0, delta * 7.0)
        right_leg.rotation_degrees.x = lerpf(right_leg.rotation_degrees.x, 0.0, delta * 7.0)

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
                mobile_dive_requested = true
            else:
                mobile_jump_requested = true
                mobile_jump_buffer = 0.28
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
