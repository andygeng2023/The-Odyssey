class_name OdysseyWaterVolume
extends Area3D

@export var surface_height := -0.04
@export var bounds := Vector3(50.0, 8.0, 27.5)
@export var bottom_height := -8.0

func _ready() -> void:
    add_to_group("water_volume")
    monitoring = true
    monitorable = true

func contains(point: Vector3) -> bool:
    return absf(point.x) <= bounds.x and absf(point.z + 27.5) <= bounds.z and point.y >= bottom_height and point.y <= surface_height + 1.5

func depth_at(point: Vector3) -> float:
    if absf(point.x) > bounds.x or absf(point.z + 27.5) > bounds.z:
        return 0.0
    return maxf(0.0, surface_height - point.y)

func is_underwater(point: Vector3) -> bool:
    return contains(point) and point.y < surface_height - 0.85
