class_name OdysseyConstructionSystem
extends Node

signal construction_started(item_id)
signal construction_completed(item_id, instance)

var inventory: OdysseyInventory
var catalog := {
	"raft": {"cost": {"wood": 12, "rope": 4}, "size": Vector3(3.0, 0.4, 5.0), "tags": ["transport", "watercraft"]},
	"bridge": {"cost": {"wood": 8, "rope": 2}, "size": Vector3(6.0, 0.3, 1.5), "tags": ["traversal", "constructible"]},
	"rope_ladder": {"cost": {"wood": 4, "rope": 2}, "size": Vector3(0.6, 3.0, 0.3), "tags": ["climbable", "constructible"]},
	"campfire": {"cost": {"wood": 3, "stone": 2}, "size": Vector3(1.0, 0.5, 1.0), "tags": ["fire", "cooking", "warmth"]}
}

func can_build(item_id: String) -> bool:
	return inventory != null and catalog.has(item_id) and inventory.has_materials(catalog[item_id].cost)

func build(item_id: String, transform: Transform3D, parent: Node3D) -> Node3D:
	if not can_build(item_id):
		return null
	var spec: Dictionary = catalog[item_id]
	inventory.consume_materials(spec.cost)
	construction_started.emit(item_id)
	var body := StaticBody3D.new()
	body.name = "Constructed_" + item_id
	body.global_transform = transform
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = spec.size
	mesh.mesh = box
	body.add_child(mesh)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = spec.size
	collision.shape = shape
	body.add_child(collision)
	var world_object := OdysseyWorldObject.new()
	world_object.name = "WorldObject"
	world_object.tags = spec.tags
	world_object.movable = false
	body.add_child(world_object)
	parent.add_child(body)
	construction_completed.emit(item_id, body)
	return body
