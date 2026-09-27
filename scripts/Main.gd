extends Node3D

@onready var inventory: OdysseyInventory = $Odysseus/Inventory
@onready var crafting: OdysseyCraftingSystem = $Systems/Crafting
@onready var discovery: OdysseyDiscoverySystem = $Systems/Discovery
@onready var player: Odysseus = $Odysseus
@onready var camera: Camera3D = $Odysseus/Camera3D

var hud_label: Label
var message_label: Label
var message_timer := 0.0
var raft_built := false
var campfire_built := false
var bridge_built := false

func _ready() -> void:
	inventory.add_material("wood", 4)
	inventory.add_material("rope", 2)
	inventory.add_material("stone", 3)
	discovery.discover("unknown_shore", "opening_coast")
	build_environment()
	build_hud()
	show_message("Washed ashore. Explore, gather, and make your own way.", 5.0)

func _process(delta: float) -> void:
	message_timer = max(0.0, message_timer - delta)
	if message_timer <= 0.0 and message_label:
		message_label.text = ""
	update_camera(delta)
	update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		if not player.try_interact():
			show_message("Nothing nearby to interact with.", 1.5)

func update_camera(delta: float) -> void:
	camera.global_position = camera.global_position.lerp(player.global_position + Vector3(0, 7, 11), min(1.0, delta * 5.0))
	camera.look_at(player.global_position + Vector3(0, 1, 0))

func build_environment() -> void:
	make_box("Water", Vector3(0, -0.15, -25), Vector3(70, 0.2, 22), Color(0.10, 0.32, 0.48, 1), false)
	make_box("Beach", Vector3(0, 0.02, -8), Vector3(70, 0.1, 12), Color(0.68, 0.56, 0.36, 1), false)
	make_box("Ridge", Vector3(10, 1.4, 9), Vector3(16, 2.8, 10), Color(0.24, 0.29, 0.20, 1), true)
	make_box("Ridge2", Vector3(-18, 1.0, 16), Vector3(20, 2.0, 8), Color(0.28, 0.31, 0.22, 1), true)

	for p in [Vector3(-12,0,5), Vector3(-7,0,11), Vector3(-2,0,7), Vector3(5,0,14), Vector3(17,0,4)]:
		make_tree(p)
	for p in [Vector3(-20,0,3), Vector3(-16,0,8), Vector3(13,0,18), Vector3(22,0,10), Vector3(2,0,22)]:
		make_rock(p)

	make_box("CampStone", Vector3(-3, 0.3, -1), Vector3(5, 0.6, 5), Color(0.31, 0.30, 0.24, 1), true)
	make_interactable(Vector3(-3, 0.75, -1), "Campfire site").setup("Build campfire", Callable(self, "build_campfire"))
	make_interactable(Vector3(7, 0.5, -10), "Raft worksite").setup("Build raft", Callable(self, "build_raft"))
	make_interactable(Vector3(17, 0.45, -2), "Bridge site").setup("Build bridge", Callable(self, "build_bridge"))
	make_interactable(Vector3(-23, 0.7, -2), "Weathered ruin").setup("Inspect ruin", Callable(self, "inspect_ruin"))
	make_interactable(Vector3(24, 0.7, 20), "Lookout").setup("Survey coast", Callable(self, "survey_coast"))

func make_tree(pos: Vector3) -> void:
	var root := make_interactable(pos, "Tree")
	root.setup("Harvest wood", Callable(self, "harvest_tree"))
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.height = 2.4
	trunk_mesh.top_radius = 0.32
	trunk_mesh.bottom_radius = 0.48
	trunk.mesh = trunk_mesh
	trunk.position.y = 1.2
	trunk.material_override = material(Color(0.29, 0.17, 0.08, 1))
	root.add_child(trunk)
	var crown := MeshInstance3D.new()
	var crown_mesh := SphereMesh.new()
	crown_mesh.radius = 1.45
	crown_mesh.height = 2.8
	crown.mesh = crown_mesh
	crown.position.y = 2.8
	crown.material_override = material(Color(0.12, 0.30, 0.14, 1))
	root.add_child(crown)
	add_static_collision(root, Vector3(0, 1.2, 0), Vector3(0.9, 2.4, 0.9))

func make_rock(pos: Vector3) -> void:
	var root := make_interactable(pos, "Stone")
	root.setup("Break stone", Callable(self, "harvest_rock"))
	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.8
	sphere.height = 1.3
	mesh.mesh = sphere
	mesh.scale = Vector3(1.2, 0.75, 1)
	mesh.material_override = material(Color(0.36, 0.38, 0.36, 1))
	root.add_child(mesh)
	add_static_collision(root, Vector3(0, 0.5, 0), Vector3(1.5, 1, 1.5))

func make_interactable(pos: Vector3, label: String) -> OdysseyPrototypeInteractable:
	var node := OdysseyPrototypeInteractable.new()
	node.name = label.replace(" ", "")
	node.position = pos
	node.add_to_group("odyssey_interactable")
	add_child(node)
	return node

func make_box(label: String, pos: Vector3, size: Vector3, color: Color, solid: bool) -> Node3D:
	var body: Node3D = StaticBody3D.new() if solid else Node3D.new()
	body.name = label
	body.position = pos
	add_child(body)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = material(color)
	body.add_child(mesh)
	if solid:
		var shape := CollisionShape3D.new()
		var collision := BoxShape3D.new()
		collision.size = size
		shape.shape = collision
		body.add_child(shape)
	return body

func add_static_collision(root: Node3D, pos: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	root.add_child(body)
	var shape := CollisionShape3D.new()
	var collision := BoxShape3D.new()
	collision.size = size
	shape.shape = collision
	body.add_child(shape)

func material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	return mat

func harvest_tree(node: Node) -> void:
	inventory.add_material("wood", 4)
	show_message("Collected wood.", 2)
	node.queue_free()

func harvest_rock(node: Node) -> void:
	inventory.add_material("stone", 3)
	show_message("Collected stone.", 2)
	node.queue_free()

func build_campfire(_node: Node) -> void:
	if campfire_built:
		show_message("The campfire is already built.", 1.5)
		return
	var result := crafting.craft(inventory, "campfire")
	if not result.ok:
		show_message("Campfire needs 3 wood and 2 stone.", 2.5)
		return
	campfire_built = true
	discovery.discover("shore_camp", "opening_coast")
	show_message("Campfire built. Preparation supports exploration.", 3)

func build_raft(_node: Node) -> void:
	if raft_built:
		show_message("Your raft is ready.", 1.5)
		return
	var result := crafting.craft(inventory, "raft")
	if not result.ok:
		show_message("Raft needs 12 wood and 4 rope.", 2.5)
		return
	raft_built = true
	make_box("Raft", Vector3(7, 0.45, -10), Vector3(4, 0.35, 2.2), Color(0.45, 0.28, 0.12, 1), false)
	discovery.discover("first_raft", "opening_coast")
	show_message("Raft built. The coastline is no longer the edge of the world.", 3)

func build_bridge(_node: Node) -> void:
	if bridge_built:
		show_message("The temporary bridge is already here.", 1.5)
		return
	var result := crafting.craft(inventory, "bridge")
	if not result.ok:
		show_message("Bridge needs 8 wood and 2 rope.", 2.5)
		return
	bridge_built = true
	make_box("Bridge", Vector3(17, 1, -2), Vector3(7, 0.3, 2), Color(0.40, 0.25, 0.12, 1), true)
	discovery.discover("temporary_bridge", "opening_coast")
	show_message("Bridge constructed. One problem, multiple solutions.", 3)

func inspect_ruin(_node: Node) -> void:
	discovery.discover("weathered_ruin", "opening_coast")
	show_message("A broken Greek marker mentions an island beyond the western horizon.", 3)

func survey_coast(_node: Node) -> void:
	discovery.discover("coastal_lookout", "opening_coast")
	show_message("From here you can see the sea, forest, and a distant island.", 3)

func build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := ColorRect.new()
	panel.position = Vector2(18, 18)
	panel.size = Vector2(430, 118)
	panel.color = Color(0.02, 0.04, 0.05, 0.78)
	layer.add_child(panel)
	hud_label = Label.new()
	hud_label.position = Vector2(32, 30)
	hud_label.add_theme_font_size_override("font_size", 16)
	layer.add_child(hud_label)
	message_label = Label.new()
	message_label.position = Vector2(32, 620)
	message_label.size = Vector2(900, 60)
	message_label.add_theme_font_size_override("font_size", 18)
	layer.add_child(message_label)

func update_hud() -> void:
	if not hud_label: return
	hud_label.text = "THE ODYSSEY — COAST SANDBOX\nWASD / arrows: move    Shift: sprint    E: interact\nWood: %d    Stone: %d    Rope: %d\nStamina: %d / %d" % [int(inventory.bulk.get("wood", 0)), int(inventory.bulk.get("stone", 0)), int(inventory.bulk.get("rope", 0)), int(player.traversal.stamina), int(player.traversal.max_stamina)]

func show_message(text: String, duration: float) -> void:
	if message_label: message_label.text = text
	message_timer = duration
