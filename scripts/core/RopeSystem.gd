class_name OdysseyRopeSystem
extends Node

signal connected(a, b)
signal disconnected(a, b)

var connections: Array[Dictionary] = []

func connect_objects(a: Node3D, b: Node3D, max_length := 8.0) -> bool:
	if a == null or b == null or a == b:
		return false
	for connection in connections:
		if (connection.a == a and connection.b == b) or (connection.a == b and connection.b == a):
			return false
	var joint := Generic6DOFJoint3D.new()
	joint.node_a = a.get_path()
	joint.node_b = b.get_path()
	joint.name = "RopeConnection"
	a.get_parent().add_child(joint)
	connections.append({"a": a, "b": b, "joint": joint, "length": max_length})
	connected.emit(a, b)
	return true

func disconnect_objects(a: Node3D, b: Node3D) -> void:
	for connection in connections.duplicate():
		if (connection.a == a and connection.b == b) or (connection.a == b and connection.b == a):
			if is_instance_valid(connection.joint):
				connection.joint.queue_free()
			connections.erase(connection)
			disconnected.emit(a, b)
