class_name OdysseyBoat
extends CharacterBody3D

signal pilot_changed(active)
var pilot: Odysseus
var speed := 5.5
var turn_speed := 1.8
var bob_time := 0.0
var deck_offset := Vector3(0.0, 0.75, 0.0)
var home_position := Vector3.ZERO

func _ready() -> void:
    home_position = global_position

func set_pilot(value: Odysseus) -> void:
    pilot = value
    pilot_changed.emit(pilot != null)
    if pilot:
        pilot.show_boat_message("You take the helm. The sea is now a route.")

func toggle_pilot(value: Odysseus) -> void:
    if pilot == value:
        pilot = null
        pilot_changed.emit(false)
        value.show_boat_message("You leave the helm.")
    elif pilot == null:
        set_pilot(value)

func _physics_process(delta: float) -> void:
    bob_time += delta
    var target_y := 0.45 + sin(bob_time * 1.7) * 0.10
    global_position.y = lerpf(global_position.y, target_y, delta * 2.0)
    if pilot and is_instance_valid(pilot):
        var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
        if pilot.mobile_controls and pilot.mobile_controls.move_vector.length_squared() > 0.01:
            input_vector = pilot.mobile_controls.move_vector
        var forward := -global_basis.z
        var desired := input_vector.y
        velocity = forward * desired * speed
        rotate_y(-input_vector.x * turn_speed * delta)
        move_and_slide()
        pilot.global_position = global_position + global_basis * deck_offset
        pilot.velocity = Vector3.ZERO
