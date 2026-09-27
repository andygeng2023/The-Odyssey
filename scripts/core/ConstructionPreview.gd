class_name OdysseyConstructionPreview
extends Node3D

var preview_mesh: MeshInstance3D
var current_size := Vector3.ONE

func setup(size: Vector3) -> void:
	current_size = size
	preview_mesh = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	preview_mesh.mesh = box
	preview_mesh.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	add_child(preview_mesh)

func move_to(transform: Transform3D) -> void:
	global_transform = transform

func valid_position(space: PhysicsDirectSpaceState3D) -> bool:
	var shape := BoxShape3D.new()
	shape.size = current_size
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = global_transform
	query.collide_with_bodies = true
	return space.intersect_shape(query, 1).is_empty()
