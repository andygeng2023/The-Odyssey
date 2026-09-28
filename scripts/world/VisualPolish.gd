class_name OdysseyVisualPolish
extends Node

func apply(world: Node3D) -> void:
    _add_terrain_layers(world)
    _add_vegetation(world)
    _add_greek_dressing(world)
    _add_path(world)
    _add_shore_foam(world)
    _add_horizon_islands(world)

func _material(color: Color, roughness: float = 0.88, metallic: float = 0.0) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material.metallic = metallic
    return material

func _mesh(world: Node3D, mesh: Mesh, pos: Vector3, color: Color, scale: Vector3 = Vector3.ONE, roughness: float = 0.88) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    node.scale = scale
    node.material_override = _material(color, roughness)
    world.add_child(node)
    return node

func _box(world: Node3D, pos: Vector3, size: Vector3, color: Color, roughness: float = 0.88) -> MeshInstance3D:
    var mesh := BoxMesh.new()
    mesh.size = size
    return _mesh(world, mesh, pos, color, Vector3.ONE, roughness)

func _cylinder(world: Node3D, pos: Vector3, radius: float, height: float, color: Color, radial: int = 8, roughness: float = 0.88) -> MeshInstance3D:
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius * 0.92
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = radial
    return _mesh(world, mesh, pos, color, Vector3.ONE, roughness)

func _add_terrain_layers(world: Node3D) -> void:
    # Broad stepped silhouettes make the island read as a real landscape instead of a flat test arena.
    var terraces := [
        [Vector3(-27, 0.65, 15), Vector3(18, 1.30, 11), Color(0.17,0.30,0.15,1)],
        [Vector3(-16, 1.05, 20), Vector3(14, 2.10, 8), Color(0.22,0.36,0.17,1)],
        [Vector3(24, 0.55, 17), Vector3(17, 1.10, 14), Color(0.20,0.34,0.16,1)],
        [Vector3(12, 1.15, 23), Vector3(13, 2.30, 8), Color(0.25,0.38,0.18,1)]
    ]
    for data in terraces:
        _box(world, data[0], data[1], data[2], 0.96)

    # Stone bands break up the grass and create readable climbable-looking landmarks.
    for x in [-31.0, -25.0, -19.0, 19.0, 25.0, 31.0]:
        var y := 0.22 + absf(sin(x)) * 0.16
        var rock := _cylinder(world, Vector3(x, y, 20.8 + cos(x) * 1.5), 1.2, 0.42, Color(0.39,0.38,0.33,1), 7)
        rock.rotation_degrees = Vector3(0, x * 7.0, 0)

func _add_vegetation(world: Node3D) -> void:
    var trees := [
        Vector3(-20,0,6), Vector3(-16,0,10), Vector3(-12,0,17), Vector3(-6,0,14),
        Vector3(3,0,12), Vector3(8,0,18), Vector3(14,0,14), Vector3(20,0,18),
        Vector3(27,0,12), Vector3(32,0,18), Vector3(-31,0,12), Vector3(-25,0,18),
        Vector3(25,0,6), Vector3(17,0,8), Vector3(-8,0,6)
    ]
    for i in trees.size():
        _tree(world, trees[i], 0.78 + float(i % 4) * 0.10)

    var flowers := [
        Vector3(-14,0.12,5), Vector3(-10,0.12,12), Vector3(-3,0.12,16),
        Vector3(5,0.12,9), Vector3(11,0.12,13), Vector3(18,0.12,6),
        Vector3(24,0.12,15), Vector3(-23,0.12,11), Vector3(29,0.12,8)
    ]
    for i in flowers.size():
        var stem := _cylinder(world, flowers[i], 0.025, 0.34, Color(0.20,0.42,0.16,1), 5)
        stem.position.y = flowers[i].y + 0.17
        var blossom := SphereMesh.new()
        blossom.radius = 0.09
        blossom.height = 0.18
        blossom.radial_segments = 7
        blossom.rings = 3
        _mesh(world, blossom, flowers[i] + Vector3(0,0.38,0), Color(0.90,0.67,0.32 if i % 2 == 0 else 0.68,1), Vector3.ONE, 0.72)

func _tree(world: Node3D, pos: Vector3, scale: float) -> void:
    var trunk := _cylinder(world, pos + Vector3(0,1.25 * scale,0), 0.22 * scale, 2.5 * scale, Color(0.25,0.13,0.055,1), 8)
    trunk.rotation_degrees.y = fmod(pos.x * 13.0, 18.0)

    for data in [
        [Vector3(0,2.20,0), 1.15],
        [Vector3(0.38,2.78,0.05), 0.82],
        [Vector3(-0.34,3.12,-0.05), 0.62]
    ]:
        var crown := CylinderMesh.new()
        crown.top_radius = 0.08
        crown.bottom_radius = float(data[1]) * scale
        crown.height = 1.05 * scale
        crown.radial_segments = 9
        _mesh(world, crown, pos + Vector3(data[0]) * scale, Color(0.055,0.27 + scale * 0.025,0.12,1), Vector3.ONE, 0.94)

func _add_greek_dressing(world: Node3D) -> void:
    # A small classical terrace gives the opening coast a strong Greek identity.
    var base := Vector3(0, 0.18, 7.0)
    _box(world, base, Vector3(8.5,0.36,5.0), Color(0.67,0.59,0.44,1), 0.78)
    _box(world, base + Vector3(0,0.25,0), Vector3(7.6,0.16,4.2), Color(0.82,0.76,0.62,1), 0.72)

    for x in [-3.0, -1.0, 1.0, 3.0]:
        _cylinder(world, base + Vector3(x,1.55,-1.45), 0.28, 2.7, Color(0.84,0.78,0.64,1), 10, 0.70)
        _cylinder(world, base + Vector3(x,2.95,-1.45), 0.36, 0.16, Color(0.69,0.59,0.43,1), 10, 0.72)
        _cylinder(world, base + Vector3(x,0.17,-1.45), 0.38, 0.14, Color(0.69,0.59,0.43,1), 10, 0.72)

    _box(world, base + Vector3(0,3.18,-1.45), Vector3(7.2,0.30,0.62), Color(0.76,0.68,0.52,1), 0.72)
    _box(world, base + Vector3(0,3.47,-1.45), Vector3(6.2,0.18,0.44), Color(0.89,0.83,0.70,1), 0.66)

    # Small olive-like grove around the terrace.
    for p in [Vector3(-5,0,5), Vector3(5,0,5), Vector3(-5,0,9), Vector3(5,0,9)]:
        _tree(world, p, 0.62)

func _add_path(world: Node3D) -> void:
    var path := [
        Vector3(-32,0.10,-1), Vector3(-28,0.10,-0.4), Vector3(-24,0.10,0.2),
        Vector3(-20,0.10,0.8), Vector3(-16,0.10,1.2), Vector3(-12,0.10,1.7),
        Vector3(-8,0.10,2.4), Vector3(-4,0.10,3.2), Vector3(0,0.10,4.2)
    ]
    for i in path.size():
        var stone := CylinderMesh.new()
        stone.top_radius = 0.55
        stone.bottom_radius = 0.68
        stone.height = 0.11
        stone.radial_segments = 7
        var n := _mesh(world, stone, path[i], Color(0.49,0.45,0.36,1), Vector3(1.35,1.0,0.76), 0.78)
        n.rotation_degrees.y = float(i * 17)

func _add_shore_foam(world: Node3D) -> void:
    # Opaque pale stepping stones plus a translucent-looking pale material at the waterline.
    var foam_mat := _material(Color(0.86,0.93,0.90,1), 0.35)
    for x in [-30.0,-24.0,-18.0,-12.0,-6.0,0.0,6.0,12.0,18.0,24.0,30.0]:
        var foam := CylinderMesh.new()
        foam.top_radius = 1.45
        foam.bottom_radius = 1.60
        foam.height = 0.035
        foam.radial_segments = 20
        var node := MeshInstance3D.new()
        node.mesh = foam
        node.position = Vector3(x,0.045,-0.25 + sin(x * 0.21) * 0.12)
        node.scale = Vector3(1.0,1.0,0.20)
        node.material_override = foam_mat
        world.add_child(node)

func _add_horizon_islands(world: Node3D) -> void:
    var data := [
        [Vector3(-44,1.0,-46), Vector3(12,2.0,7), Color(0.12,0.24,0.18,1)],
        [Vector3(38,0.8,-43), Vector3(9,1.6,6), Color(0.15,0.28,0.20,1)],
        [Vector3(3,0.2,-55), Vector3(18,0.8,5), Color(0.11,0.22,0.19,1)]
    ]
    for item in data:
        var island := CylinderMesh.new()
        island.top_radius = 0.68
        island.bottom_radius = 1.0
        island.height = 2.0
        island.radial_segments = 9
        _mesh(world, island, item[0], item[2], item[1], 0.96)
