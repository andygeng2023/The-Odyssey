class_name OdysseySystemicActionSystem
extends Node

signal action_feedback(message: String)

@export var reach := 4.5
@export var break_strength := 34.0

var inventory: OdysseyInventory
var player: Odysseus
var camera: Camera3D
var physics_system: OdysseyPhysicsInteractionSystem
var fire_system: OdysseyFireSystem

func configure(p_inventory: OdysseyInventory, p_player: Odysseus, p_camera: Camera3D, p_physics: OdysseyPhysicsInteractionSystem, p_fire: OdysseyFireSystem) -> void:
	inventory = p_inventory
	player = p_player
	camera = p_camera
	physics_system = p_physics
	fire_system = p_fire

func try_action() -> bool:
	if player == null or camera == null:
		return false
	if physics_system != null and physics_system.held_object != null:
		physics_system.throw(player, -camera.global_basis.z)
		action_feedback.emit("Thrown")
		return true

	var target := _raycast_target()
	if target == null:
		return false

	var world_object := _find_world_object(target)
	if world_object != null:
		if _try_grab(target, world_object):
			return true
		if _try_harvest(world_object):
			return true
		if _try_burn(world_object):
			return true
		if _try_break(world_object):
			return true

	if target is RigidBody3D:
		var body := target as RigidBody3D
		body.apply_central_impulse((-camera.global_basis.z).normalized() * 3.5 * maxf(body.mass, 0.1))
		action_feedback.emit("Pushed")
		return true
	return false

func _raycast_target() -> Node3D:
	var from := camera.global_position
	var to := from + -camera.global_basis.z * reach
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null
	return hit.get("collider") as Node3D

func _find_world_object(target: Node3D) -> OdysseyWorldObject:
	var current: Node = target
	while current != null:
		var object := current.get_node_or_null("WorldObject") as OdysseyWorldObject
		if object != null:
			return object
		if current is OdysseyWorldObject:
			return current as OdysseyWorldObject
		current = current.get_parent()
	return null

func _try_grab(target: Node3D, object: OdysseyWorldObject) -> bool:
	if not object.movable or physics_system == null:
		return false
	var body := target as RigidBody3D
	if body == null:
		body = object.get_parent() as RigidBody3D
	if body == null:
		return false
	if physics_system.try_grab(player, camera):
		action_feedback.emit("Grabbed %s" % object.display_name())
		return true
	return false

func _try_harvest(object: OdysseyWorldObject) -> bool:
	if not object.can("harvest") or inventory == null:
		return false
	var amount := maxi(1, object.quantity)
	inventory.add_material(object.material_id, amount)
	object.apply_damage(object.harvest_damage)
	action_feedback.emit("Gathered %d %s" % [amount, object.display_name()])
	return true

func _try_burn(object: OdysseyWorldObject) -> bool:
	if not object.can("burn") or fire_system == null:
		return false
	var source := object.get_parent() as Node3D
	if source == null:
		source = object
	if fire_system.ignite(source):
		action_feedback.emit("Lit %s" % object.display_name())
		return true
	return false

func _try_break(object: OdysseyWorldObject) -> bool:
	if not object.can("break"):
		return false
	if object.apply_damage(break_strength):
		if inventory != null and not object.material_id.is_empty():
			inventory.add_material(object.material_id, maxi(1, object.quantity))
		action_feedback.emit("Broke %s" % object.display_name())
	else:
		action_feedback.emit("Damaged %s" % object.display_name())
	return true
