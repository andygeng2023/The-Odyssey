class_name OdysseyWorldGenerator
extends Node3D

var inventory: OdysseyInventory
var discovery: OdysseyDiscoverySystem
var crafting: OdysseyCraftingSystem
var campfire_built := false
var raft_built := false
var bridge_built := false

func build_shore(p_inventory: OdysseyInventory, p_discovery: OdysseyDiscoverySystem) -> void:
    inventory = p_inventory
    discovery = p_discovery
    crafting = get_parent().get_node("Systems/Crafting")
    _make_box("Water", Vector3(0, -0.15, -25), Vector3(70, 0.2, 22), Color(0.10, 0.32, 0.48, 1), false)
    _make_box("Beach", Vector3(0, 0.02, -8), Vector3(70, 0.1, 12), Color(0.68, 0.56, 0.36, 1), false)
    _make_box("Ridge", Vector3(10, 1.4, 9), Vector3(16, 2.8, 10), Color(0.24, 0.29, 0.20, 1), true)
    _make_box("Ridge2", Vector3(-18, 1.0, 16), Vector3(20, 2.0, 8), Color(0.28, 0.31, 0.22, 1), true)
    for p in [Vector3(-12,0,5), Vector3(-7,0,11), Vector3(-2,0,7), Vector3(5,0,14), Vector3(17,0,4)]:
        _make_tree(p)
    for p in [Vector3(-20,0,3), Vector3(-16,0,8), Vector3(13,0,18), Vector3(22,0,10), Vector3(2,0,22)]:
        _make_rock(p)
    _make_interactable(Vector3(-3, 0.75, -1), "Campfire site", "Build campfire", _build_campfire)
    _make_interactable(Vector3(7, 0.5, -10), "Raft worksite", "Build raft", _build_raft)
    _make_interactable(Vector3(17, 0.45, -2), "Bridge site", "Build bridge", _build_bridge)
    _make_interactable(Vector3(-23, 0.7, -2), "Weathered ruin", "Inspect ruin", _inspect_ruin)
    _make_interactable(Vector3(24, 0.7, 20), "Lookout", "Survey coast", _survey_coast)

func _make_tree(pos: Vector3) -> void:
    var root := _make_interactable(pos, "Tree", "Harvest wood", _harvest_tree)
    var trunk := MeshInstance3D.new()
    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.height = 2.4
    trunk_mesh.top_radius = 0.32
    trunk_mesh.bottom_radius = 0.48
    trunk.mesh = trunk_mesh
    trunk.position.y = 1.2
    trunk.material_override = _material(Color(0.29, 0.17, 0.08, 1))
    root.add_child(trunk)
    var crown := MeshInstance3D.new()
    var crown_mesh := SphereMesh.new()
    crown_mesh.radius = 1.45
    crown_mesh.height = 2.8
    crown.mesh = crown_mesh
    crown.position.y = 2.8
    crown.material_override = _material(Color(0.12, 0.30, 0.14, 1))
    root.add_child(crown)
    _add_collision(root, Vector3(0, 1.2, 0), Vector3(0.9, 2.4, 0.9))

func _make_rock(pos: Vector3) -> void:
    var root := _make_interactable(pos, "Stone", "Gather stone", _harvest_rock)
    var mesh := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.8
    sphere.height = 1.3
    mesh.mesh = sphere
    mesh.scale = Vector3(1.2, 0.75, 1)
    mesh.material_override = _material(Color(0.36, 0.38, 0.36, 1))
    root.add_child(mesh)
    _add_collision(root, Vector3(0, 0.5, 0), Vector3(1.5, 1, 1.5))

func _make_interactable(pos: Vector3, node_name: String, action_name: String, callback: Callable) -> OdysseyPrototypeInteractable:
    var node := OdysseyPrototypeInteractable.new()
    node.name = node_name.replace(" ", "")
    node.position = pos
    node.add_to_group("odyssey_interactable")
    node.setup(action_name, callback)
    add_child(node)
    return node

func _make_box(label: String, pos: Vector3, size: Vector3, color: Color, solid: bool) -> Node3D:
    var body: Node3D = StaticBody3D.new() if solid else Node3D.new()
    body.name = label
    body.position = pos
    add_child(body)
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    mesh.material_override = _material(color)
    body.add_child(mesh)
    if solid:
        var shape := CollisionShape3D.new()
        var collision := BoxShape3D.new()
        collision.size = size
        shape.shape = collision
        body.add_child(shape)
    return body

func _add_collision(root: Node3D, pos: Vector3, size: Vector3) -> void:
    var body := StaticBody3D.new()
    body.position = pos
    root.add_child(body)
    var shape := CollisionShape3D.new()
    var collision := BoxShape3D.new()
    collision.size = size
    shape.shape = collision
    body.add_child(shape)

func _material(color: Color) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.9
    return mat

func _harvest_tree(node: Node, _player: Node = null) -> void:
    inventory.add_material("wood", 4)
    _message("Collected wood.")
    node.queue_free()

func _harvest_rock(node: Node, _player: Node = null) -> void:
    inventory.add_material("stone", 3)
    _message("Collected stone.")
    node.queue_free()

func _build_campfire(_node: Node, _player: Node = null) -> void:
    if campfire_built:
        _message("The campfire is already built.")
        return
    var result := crafting.craft(inventory, "campfire")
    if not result.ok:
        _message("Campfire needs 3 wood and 2 stone.")
        return
    campfire_built = true
    discovery.discover("shore_camp", "opening_coast")
    _message("Campfire built. Preparation supports exploration.")

func _build_raft(_node: Node, _player: Node = null) -> void:
    if raft_built:
        _message("Your raft is ready.")
        return
    var result := crafting.craft(inventory, "raft")
    if not result.ok:
        _message("Raft needs 12 wood and 4 rope.")
        return
    raft_built = true
    _make_box("Raft", Vector3(7, 0.45, -10), Vector3(4, 0.35, 2.2), Color(0.45, 0.28, 0.12, 1), false)
    discovery.discover("first_raft", "opening_coast")
    _message("Raft built. The coastline is no longer the edge of the world.")

func _build_bridge(_node: Node, _player: Node = null) -> void:
    if bridge_built:
        _message("The temporary bridge is already here.")
        return
    var result := crafting.craft(inventory, "bridge")
    if not result.ok:
        _message("Bridge needs 8 wood and 2 rope.")
        return
    bridge_built = true
    _make_box("Bridge", Vector3(17, 1, -2), Vector3(7, 0.3, 2), Color(0.40, 0.25, 0.12, 1), true)
    discovery.discover("temporary_bridge", "opening_coast")
    _message("Bridge constructed. One problem, multiple solutions.")

func _inspect_ruin(_node: Node, _player: Node = null) -> void:
    discovery.discover("weathered_ruin", "opening_coast")
    _message("A broken Greek marker mentions an island beyond the western horizon.")

func _survey_coast(_node: Node, _player: Node = null) -> void:
    discovery.discover("coastal_lookout", "opening_coast")
    _message("From here you can see the sea, forest, and a distant island.")

func _message(text: String) -> void:
    var hud := get_parent().get_parent().get_node_or_null("UI/GameHUD") as OdysseyGameHUD
    if hud:
        hud.show_message(text, 3.0)
