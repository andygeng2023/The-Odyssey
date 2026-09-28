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
    _make_water()
    _make_terrain()
    for p in [Vector3(-12,0,5), Vector3(-7,0,11), Vector3(-2,0,7), Vector3(5,0,14), Vector3(17,0,4), Vector3(-28,0,14), Vector3(28,0,14)]:
        _make_tree(p)
    for p in [Vector3(-20,0,3), Vector3(-16,0,8), Vector3(13,0,18), Vector3(22,0,10), Vector3(2,0,22), Vector3(-30,0,8)]:
        _make_rock(p)
    _make_interactable(Vector3(-3, 0.75, -1), "Campfire site", "Build campfire", _build_campfire)
    _make_interactable(Vector3(7, 0.5, -10), "Raft worksite", "Build raft", _build_raft)
    _make_interactable(Vector3(17, 0.45, -2), "Bridge site", "Build bridge", _build_bridge)
    _make_interactable(Vector3(-23, 0.7, -2), "Weathered ruin", "Inspect ruin", _inspect_ruin)
    _make_interactable(Vector3(24, 0.7, 20), "Lookout", "Survey coast", _survey_coast)
    _make_city(Vector3(-34, 0, -2))
    _make_shrine(Vector3(31, 0, 2))
    _make_underwater_gate(Vector3(25, -0.5, -18))
    _make_realm_gate(Vector3(-30, 0, -18), "Underworld", Color(0.10, 0.05, 0.12, 1), "underworld_gate")
    _make_realm_gate(Vector3(30, 0, -18), "Heavens", Color(0.72, 0.80, 0.95, 1), "heavens_gate")
    _make_calypso_horizon()
    _make_wildlife(Vector3(-10, 0, 18), "Deer")
    _make_wildlife(Vector3(20, 0, 13), "Goat")

func _make_water() -> void:
    var water := MeshInstance3D.new()
    water.name = "Sea"
    var mesh := PlaneMesh.new()
    mesh.size = Vector2(120, 60)
    mesh.subdivide_width = 24
    mesh.subdivide_depth = 12
    water.mesh = mesh
    water.position = Vector3(0, -0.04, -25)
    var shader := Shader.new()
    shader.code = """
shader_type spatial;
render_mode blend_mix, cull_disabled;
uniform vec4 water_color : source_color = vec4(0.035, 0.32, 0.48, 0.82);
uniform float wave_height = 0.10;
uniform float wave_scale = 0.22;
void vertex() {
    float wave_a = sin(VERTEX.x * wave_scale + TIME * 0.75);
    float wave_b = cos(VERTEX.z * wave_scale * 1.7 + TIME * 0.52);
    VERTEX.y += (wave_a + wave_b) * wave_height * 0.5;
}
void fragment() {
    float shimmer = 0.08 * sin(UV.x * 80.0 + TIME * 1.5);
    ALBEDO = water_color.rgb + vec3(shimmer);
    ROUGHNESS = 0.12;
    METALLIC = 0.08;
    ALPHA = water_color.a;
}
"""
    var mat := ShaderMaterial.new()
    mat.shader = shader
    water.material_override = mat
    add_child(water)

func _make_terrain() -> void:
    _make_box("Beach", Vector3(0, 0.03, -8), Vector3(100, 0.1, 18), Color(0.82, 0.70, 0.50, 1), false)
    _make_landform("HillWest", Vector3(-23, 1.9, 10), Vector3(20, 3.8, 15), Color(0.20, 0.34, 0.18, 1))
    _make_landform("HillWestRidge", Vector3(-14, 2.6, 17), Vector3(13, 5.2, 9), Color(0.25, 0.39, 0.20, 1))
    _make_landform("HillEast", Vector3(23, 1.5, 13), Vector3(18, 3.0, 18), Color(0.24, 0.39, 0.19, 1))
    _make_landform("HillEastRidge", Vector3(14, 2.2, 20), Vector3(12, 4.4, 10), Color(0.29, 0.43, 0.21, 1))
    _make_landform("Cliff", Vector3(0, 2.3, 28), Vector3(72, 4.6, 8), Color(0.32, 0.31, 0.27, 1))
    _make_box("CliffFace", Vector3(0, 1.15, 24), Vector3(72, 2.3, 1.2), Color(0.22, 0.24, 0.23, 1), true)
    for x in [-30.0, -22.0, -14.0, -5.0, 5.0, 14.0, 23.0, 31.0]:
        _make_landform("RockOutcrop", Vector3(x, 0.65, 19.0 + sin(x) * 2.0), Vector3(3.2, 1.3, 2.4), Color(0.40, 0.39, 0.34, 1))

func _make_tree(pos: Vector3) -> void:
    var root := _make_interactable(pos, "Tree", "Harvest wood", _harvest_tree)
    var trunk := MeshInstance3D.new()
    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.height = 3.4
    trunk_mesh.top_radius = 0.18
    trunk_mesh.bottom_radius = 0.38
    trunk.mesh = trunk_mesh
    trunk.position.y = 1.7
    trunk.material_override = _material(Color(0.27, 0.13, 0.055, 1))
    root.add_child(trunk)
    for data in [[Vector3(0,3.1,0),1.45,1.55],[Vector3(0.52,2.65,0.18),0.95,1.25],[Vector3(-0.55,2.45,-0.2),0.82,1.05]]:
        var crown := MeshInstance3D.new()
        var crown_mesh := SphereMesh.new()
        crown_mesh.radius = data[1]
        crown_mesh.height = data[2]
        crown.mesh = crown_mesh
        crown.position = data[0]
        crown.material_override = _material(Color(0.08, 0.28, 0.12, 1))
        root.add_child(crown)
    var branch := MeshInstance3D.new()
    var branch_mesh := CylinderMesh.new()
    branch_mesh.height = 1.6
    branch_mesh.top_radius = 0.07
    branch_mesh.bottom_radius = 0.14
    branch.mesh = branch_mesh
    branch.rotation_degrees = Vector3(0, 0, -55)
    branch.position = Vector3(0.35, 2.15, 0)
    branch.material_override = _material(Color(0.25, 0.12, 0.05, 1))
    root.add_child(branch)
    _add_collision(root, Vector3(0, 1.7, 0), Vector3(0.8, 3.4, 0.8))

func _make_rock(pos: Vector3) -> void:
    var root := _make_interactable(pos, "Stone", "Gather stone", _harvest_rock)
    var mesh := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.85
    sphere.height = 1.4
    mesh.mesh = sphere
    mesh.scale = Vector3(1.4, 0.8, 1.0)
    mesh.material_override = _material(Color(0.39, 0.41, 0.40, 1))
    root.add_child(mesh)
    _add_collision(root, Vector3(0, 0.5, 0), Vector3(1.6, 1, 1.6))

func _make_city(pos: Vector3) -> void:
    var root := Node3D.new()
    root.name = "AegeanCity"
    root.position = pos
    add_child(root)
    _label(root, "AEGEAN CITY", Vector3(0, 5.5, 0))
    for x in [-4.0, 0.0, 4.0]:
        _make_house(root, Vector3(x, 0, 0), 3.0)
    _make_box_child(root, "Gate", Vector3(0, 2.2, -4), Vector3(10, 4.4, 1), Color(0.72, 0.62, 0.43, 1))
    _make_interactable(pos + Vector3(0,0,-5.5), "City gate", "Enter Aegean city", _enter_city)

func _make_house(parent: Node3D, pos: Vector3, scale: float) -> void:
    _make_box_child(parent, "House", pos + Vector3(0,1.15,0), Vector3(scale,2.3,scale), Color(0.72,0.66,0.54,1))
    _make_box_child(parent, "Trim", pos + Vector3(0,2.30,0), Vector3(scale*1.08,0.16,scale*1.08), Color(0.86,0.80,0.67,1))
    var roof := MeshInstance3D.new()
    var roof_mesh := CylinderMesh.new()
    roof_mesh.top_radius = 0.0
    roof_mesh.bottom_radius = scale * 0.78
    roof_mesh.height = 0.75
    roof_mesh.radial_segments = 4
    roof.mesh = roof_mesh
    roof.position = pos + Vector3(0,2.72,0)
    roof.rotation_degrees.y = 45.0
    roof.material_override = _material(Color(0.48,0.24,0.13,1))
    parent.add_child(roof)
    for x in [-scale * 0.32, scale * 0.32]:
        _make_box_child(parent, "DoorFrame", pos + Vector3(x,0.85,-scale*0.51), Vector3(0.18,1.7,0.12), Color(0.38,0.25,0.16,1))

func _make_shrine(pos: Vector3) -> void:
    var root := Node3D.new()
    root.name = "AthenaShrine"
    root.position = pos
    add_child(root)
    _label(root, "SHRINE OF ATHENA", Vector3(0,4.5,0))
    for x in [-2.4, 2.4]:
        for z in [-1.6, 1.6]:
            _make_cylinder_child(root, Vector3(x,1.4,z), 0.35, 2.8, Color(0.83,0.78,0.63,1))
    _make_box_child(root, "Altar", Vector3(0,0.7,0), Vector3(4,1.0,2.5), Color(0.64,0.58,0.45,1))
    _make_interactable(pos + Vector3(0,0.7,3), "Athena shrine", "Pray / listen", _visit_shrine)

func _make_underwater_gate(pos: Vector3) -> void:
    var root := Node3D.new()
    root.name = "SunkenCave"
    root.position = pos
    add_child(root)
    _label(root, "SUNKEN CAVE", Vector3(0,3,0))
    _make_box_child(root, "LeftPillar", Vector3(-2,1.8,0), Vector3(0.8,3.6,0.8), Color(0.22,0.30,0.34,1))
    _make_box_child(root, "RightPillar", Vector3(2,1.8,0), Vector3(0.8,3.6,0.8), Color(0.22,0.30,0.34,1))
    _make_interactable(pos + Vector3(0,0.5,1.5), "Sunken cave", "Dive into cave", _enter_underwater)

func _make_realm_gate(pos: Vector3, title: String, color: Color, discovery_id: String) -> void:
    var root := Node3D.new()
    root.name = title.replace(" ", "")
    root.position = pos
    add_child(root)
    _label(root, title.to_upper(), Vector3(0,5,0))
    var ring := MeshInstance3D.new()
    var torus := TorusMesh.new()
    torus.inner_radius = 1.7
    torus.outer_radius = 2.1
    ring.mesh = torus
    ring.rotation_degrees.x = 90
    ring.material_override = _material(color)
    root.add_child(ring)
    _make_interactable(pos + Vector3(0,0,2.2), title + " gate", "Discover " + title, _discover_realm.bind(discovery_id, title))

func _make_calypso_horizon() -> void:
    var island := Node3D.new()
    island.name = "CalypsoIsland"
    island.position = Vector3(0, 1.0, -46)
    add_child(island)
    _make_box_child(island, "Island", Vector3(0,0,0), Vector3(18,2,8), Color(0.20,0.35,0.19,1))
    for x in [-5,0,5]:
        _make_tree_child(island, Vector3(x,1,0))
    _label(island, "CALYPSO'S ISLAND", Vector3(0,5,0))
    _make_interactable(Vector3(0,0.4,-28), "Distant island", "Chart Calypso's island", _discover_calypso)

func _make_wildlife(pos: Vector3, species: String) -> void:
    var animal := OdysseyWildlifeAgent.new()
    animal.name = species
    animal.position = pos
    animal.speed = 0.7 if species == "Deer" else 0.55
    add_child(animal)
    var body := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.35
    mesh.height = 0.9
    body.mesh = mesh
    body.material_override = _material(Color(0.48,0.31,0.16,1))
    body.position.y = 0.65
    animal.add_child(body)
    var animal_collision := CollisionShape3D.new()
    var animal_shape := CapsuleShape3D.new()
    animal_shape.radius = 0.35
    animal_shape.height = 0.9
    animal_collision.shape = animal_shape
    animal_collision.position = Vector3(0, 0.65, 0)
    var animal_body := StaticBody3D.new()
    animal.add_child(animal_body)
    animal_body.add_child(animal_collision)
    _label(animal, species.to_upper(), Vector3(0,1.8,0))

func _make_interactable(pos: Vector3, node_name: String, action_name: String, callback: Callable) -> OdysseyPrototypeInteractable:
    var node := OdysseyPrototypeInteractable.new()
    node.name = node_name.replace(" ", "")
    node.position = pos
    node.add_to_group("odyssey_interactable")
    node.setup(action_name, callback)
    add_child(node)
    return node

func _make_landform(label: String, pos: Vector3, scale: Vector3, color: Color) -> void:
    var root := Node3D.new()
    root.name = label
    root.position = pos
    add_child(root)
    var mesh := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 1.0
    sphere.height = 2.0
    mesh.mesh = sphere
    mesh.scale = scale
    mesh.material_override = _material(color)
    root.add_child(mesh)

    # Match the visible terrain with a scaled sphere collider so hills and outcrops are physical.
    var body := StaticBody3D.new()
    root.add_child(body)
    var shape := CollisionShape3D.new()
    var collision := SphereShape3D.new()
    collision.radius = 1.0
    shape.shape = collision
    shape.scale = scale
    body.add_child(shape)

func _make_box(label: String, pos: Vector3, size: Vector3, color: Color, solid: bool) -> Node3D:
    var body: Node3D = StaticBody3D.new() if solid else Node3D.new()
    body.name = label
    body.position = pos
    add_child(body)
    _make_box_mesh(body, size, color)
    if solid:
        var shape := CollisionShape3D.new()
        var collision := BoxShape3D.new()
        collision.size = size
        shape.shape = collision
        body.add_child(shape)
    return body

func _make_box_child(parent: Node3D, label: String, pos: Vector3, size: Vector3, color: Color) -> void:
    var body := StaticBody3D.new()
    body.name = label
    body.position = pos
    parent.add_child(body)
    _make_box_mesh(body, size, color)
    var shape := CollisionShape3D.new()
    var collision := BoxShape3D.new()
    collision.size = size
    shape.shape = collision
    body.add_child(shape)

func _make_box_mesh(parent: Node3D, size: Vector3, color: Color) -> void:
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    mesh.material_override = _material(color)
    parent.add_child(mesh)

func _make_cylinder_child(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color) -> void:
    var body := StaticBody3D.new()
    body.position = pos
    parent.add_child(body)
    var mesh := MeshInstance3D.new()
    var cylinder := CylinderMesh.new()
    cylinder.top_radius = radius
    cylinder.bottom_radius = radius * 1.15
    cylinder.height = height
    mesh.mesh = cylinder
    mesh.material_override = _material(color)
    body.add_child(mesh)
    var shape := CollisionShape3D.new()
    var collision := CylinderShape3D.new()
    collision.radius = radius * 1.15
    collision.height = height
    shape.shape = collision
    body.add_child(shape)

func _make_tree_child(parent: Node3D, pos: Vector3) -> void:
    var body := StaticBody3D.new()
    body.position = pos + Vector3(0, 1.25, 0)
    parent.add_child(body)
    var trunk := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.height = 2.5
    mesh.top_radius = 0.22
    mesh.bottom_radius = 0.38
    trunk.mesh = mesh
    trunk.material_override = _material(Color(0.30,0.17,0.07,1))
    body.add_child(trunk)
    var shape := CollisionShape3D.new()
    var collision := CylinderShape3D.new()
    collision.radius = 0.38
    collision.height = 2.5
    shape.shape = collision
    body.add_child(shape)
    var crown := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 1.15
    sphere.height = 2.1
    crown.mesh = sphere
    crown.position = pos + Vector3(0,2.8,0)
    crown.material_override = _material(Color(0.10,0.31,0.15,1))
    parent.add_child(crown)

func _label(parent: Node3D, text: String, pos: Vector3) -> void:
    var label := Label3D.new()
    label.text = text
    label.position = pos
    label.font_size = 28
    label.outline_size = 8
    label.modulate = Color(1,0.94,0.78,0.9)
    parent.add_child(label)

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
    mat.roughness = 0.72
    mat.metallic = 0.04
    mat.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
    mat.cull_mode = BaseMaterial3D.CULL_BACK
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
    _message("Campfire built. Rest, warmth and cooking belong in the survival loop.")

func _build_raft(_node: Node, _player: Node = null) -> void:
    if raft_built:
        _message("Your raft is ready.")
        return
    var result := crafting.craft(inventory, "raft")
    if not result.ok:
        _message("Raft needs 12 wood and 4 rope.")
        return
    raft_built = true
    _make_box("Raft", Vector3(7, 0.45, -10), Vector3(4, 0.35, 2.2), Color(0.45,0.28,0.12,1), false)
    discovery.discover("first_raft", "opening_coast")
    _message("Raft built. Water becomes a route instead of a boundary.")

func _build_bridge(_node: Node, _player: Node = null) -> void:
    if bridge_built:
        _message("The temporary bridge is already here.")
        return
    var result := crafting.craft(inventory, "bridge")
    if not result.ok:
        _message("Bridge needs 8 wood and 2 rope.")
        return
    bridge_built = true
    _make_box("Bridge", Vector3(17, 1, -2), Vector3(7,0.3,2), Color(0.40,0.25,0.12,1), true)
    discovery.discover("temporary_bridge", "opening_coast")
    _message("Bridge constructed. Physical solutions are part of the design.")

func _inspect_ruin(_node: Node, _player: Node = null) -> void:
    discovery.discover("weathered_ruin", "opening_coast")
    _message("The ruin points toward islands, cities and older powers.")

func _survey_coast(_node: Node, _player: Node = null) -> void:
    discovery.discover("coastal_lookout", "opening_coast")
    _message("You can see a city, a shrine, a sunken cave and distant mythic gates.")

func _enter_city(_node: Node, _player: Node = null) -> void:
    discovery.discover("aegean_city", "civilization")
    _message("Aegean city discovered: merchants, craftsmen, sailors and relationships are coming online.")

func _visit_shrine(_node: Node, _player: Node = null) -> void:
    discovery.discover("athena_shrine", "mythology")
    _message("The shrine answers with a sign: gods can alter the journey without becoming a quest marker checklist.")

func _enter_underwater(_node: Node, _player: Node = null) -> void:
    discovery.discover("sunken_cave", "underwater")
    _message("Dive route discovered: submerged ruins, wildlife and treasure belong beneath the surface.")

func _discover_realm(discovery_id: String, title: String, _node: Node = null, _player: Node = null) -> void:
    discovery.discover(discovery_id, "mythic_realms")
    _message(title + " discovered. The realm is now a destination rather than a forced story corridor.")

func _discover_calypso(_node: Node, _player: Node = null) -> void:
    discovery.discover("calypso_island", "calypso")
    _message("Calypso's island charted. Its story will be discovered through exploration and relationships.")

func _message(text: String) -> void:
    var hud := get_parent().get_node_or_null("UI/GameHUD") as OdysseyGameHUD
    if hud:
        hud.show_message(text, 4.0)