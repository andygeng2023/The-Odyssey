class_name OdysseyDiscoverySystem
extends Node

signal discovered(id)
signal map_changed

var discovered_locations: Dictionary = {}
var revealed_map_regions: Dictionary = {}
var landmarks: Dictionary = {}

func discover(id: String, region: String = "") -> void:
    if not discovered_locations.has(id):
        discovered_locations[id] = Time.get_ticks_msec()
        if region != "":
            revealed_map_regions[region] = true
        discovered.emit(id)
        map_changed.emit()

func register_landmark(id: String, title: String, position: Vector3, region: String) -> void:
    landmarks[id] = {"title": title, "position": position, "region": region}

func is_discovered(id: String) -> bool:
    return discovered_locations.has(id)

func can_fast_travel_to(id: String) -> bool:
    return is_discovered(id)

func fast_travel(id: String) -> Vector3:
    if not can_fast_travel_to(id):
        return Vector3.INF
    return landmarks.get(id, {}).get("position", Vector3.INF)

func map_text() -> String:
    var lines: Array[String] = []
    for id in landmarks.keys():
        var entry: Dictionary = landmarks[id]
        var marker := "• " if is_discovered(id) else "○ "
        lines.append(marker + str(entry.title) + "  [" + str(entry.region) + "]")
    if lines.is_empty():
        return "Explore the coastline to reveal landmarks."
    return "\n".join(lines)
