class_name OdysseyVisualPolish
extends Node

func apply(world: Node3D) -> void:
    _add_grass(world)
    _add_flowers(world)
    _add_path(world)
    _add_shore_foam(world)
    _add_horizon_islands(world)

func _material(color: Color, roughness := 0.9) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    return material

func _mesh(world: Node3D, mesh: Mesh, pos: Vector3, color: Color, scale := Vector3.ONE) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    node.scale = scale
    node.material_override = _material(color)
    world.add_child(node)
    return node

func _add_grass(world: Node3D) -> void:
    var positions := [
        Vector3(-18,0.08,4), Vector3(-15,0.08,8), Vector3(-11,0.08,15),
        Vector3(-6,0.08,17), Vector3(1,0.08,11), Vector3(8,0.08,16),
        Vector3(12,0.08,12), Vector3(18,0.08,17), Vector3(26,0.08,15),
        Vector3(-27,0.08,8), Vector3(-32,0.08,12), Vector3(29,0.08,8),
        Vector3(6,0.08,6), Vector3(-4,0.08,4), Vector3(20,0.08,6)
    ]
    for i in positions.size():
        var blade := CylinderMesh.new()
        blade.top_radius = 0.018
        blade.bottom_radius = 0.055
        blade.height = 0.42 + float(i % 3) * 0.08
        blade.radial_segments = 4
        _mesh(world, blade, positions[i], Color(0.20,0.48,0.20,1), Vector3(1.0 + float(i % 2) * 0.35, 1.0, 1.0))

func _add_flowers(world: Node3D) -> void:
    var positions := [
        Vector3(-13,0.18,5), Vector3(-8,0.18,14), Vector3(4,0.18,15),
        Vector3(11,0.18,7), Vector3(22,0.18,14), Vector3(-24,0.18,12)
    ]
    for p in positions:
        var stem := CylinderMesh.new()
        stem.top_radius = 0.018
        stem.bottom_radius = 0.025
        stem.height = 0.30
        stem.radial_segments = 5
        _mesh(world, stem, p, Color(0.25,0.48,0.20,1))
        var flower := SphereMesh.new()
        flower.radius = 0.08
        flower.height = 0.16
        flower.radial_segments = 6
        flower.rings = 3
        _mesh(world, flower, p + Vector3(0,0.18,0), Color(0.93,0.72,0.38,1))

func _add_path(world: Node3D) -> void:
    var path := [
        Vector3(-32,0.08,-1), Vector3(-28,0.08,-0.4), Vector3(-24,0.08,0.2),
        Vector3(-20,0.08,0.8), Vector3(-16,0.08,1.2), Vector3(-12,0.08,1.7)
    ]
    for i in path.size():
        var stone := CylinderMesh.new()
        stone.top_radius = 0.48
        stone.bottom_radius = 0.58
        stone.height = 0.10
        stone.radial_segments = 6
        var n := _mesh(world, stone, path[i], Color(0.48,0.45,0.37,1), Vector3(1.25,1.0,0.72))
        n.rotation_degrees.y = float(i * 17)

func _add_shore_foam(world: Node3D) -> void:
    var foam_positions := [
        Vector3(-30,0.035,-0.3), Vector3(-18,0.035,-0.3), Vector3(-6,0.035,-0.3),
        Vector3(6,0.035,-0.3), Vector3(18,0.035,-0.3), Vector3(30,0.035,-0.3)
    ]
    for p in foam_positions:
        var foam := CylinderMesh.new()
        foam.top_radius = 1.5
        foam.bottom_radius = 1.5
        foam.height = 0.025
        foam.radial_segments = 24
        _mesh(world, foam, p, Color(0.88,0.93,0.90,0.34), Vector3(1.0,1.0,0.18))

func _add_horizon_islands(world: Node3D) -> void:
    var data := [
        [Vector3(-44,1.0,-46), Vector3(12,2.0,7), Color(0.18,0.32,0.20,1)],
        [Vector3(38,0.8,-43), Vector3(9,1.6,6), Color(0.22,0.36,0.22,1)]
    ]
    for item in data:
        var island := CylinderMesh.new()
        island.top_radius = 0.68
        island.bottom_radius = 1.0
        island.height = 2.0
        island.radial_segments = 8
        _mesh(world, island, item[0], item[2], item[1])
