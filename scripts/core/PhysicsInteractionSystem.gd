class_name OdysseyPhysicsInteractionSystem
extends Node

signal grabbed(actor, object)
signal released(actor, object)
signal action_applied(actor, object, action)

@export var reach := 3.0
@export var throw_impulse := 8.0
var held_object: RigidBody3D = null
var held_offset := Vector3(0, 1.2, -1.5)

func try_grab(actor: Node3D, camera: Camera3D) -> bool:
	if held_object != null:
		return false
	var from := camera.global_position
	var to := from + -camera.global_basis.z * reach
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	var hit := actor.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return false
	var body := hit.get("collider") as RigidBody3D
	if body == null:
		return false
	var object := body.get_node_or_null("WorldObject") as OdysseyWorldObject
	if object != null and not object.movable:
		return false
	held_object = body
	held_object.freeze = true
	grabbed.emit(actor, body)
	return true

func release(actor: Node3D) -> void:
	if held_object == null:
		return
	held_object.freeze = false
	released.emit(actor, held_object)
	held_object = null

func throw(actor: Node3D, direction: Vector3) -> void:
	if held_object == null:
		return
	var body := held_object
	held_object = null
	body.freeze = false
	body.apply_central_impulse(direction.normalized() * throw_impulse * max(body.mass, 0.1))
	released.emit(actor, body)

func carry_position(actor: Node3D, camera: Camera3D) -> void:
	if held_object == null:
		return
	held_object.global_position = camera.global_transform * held_offset

func apply_object_action(actor: Node, target: OdysseyWorldObject, action: String, strength := 10.0) -> bool:
	if target == null or not target.can(action):
		return false
	if action == "break":
		target.apply_damage(strength)
	action_applied.emit(actor, target, action)
	return true
