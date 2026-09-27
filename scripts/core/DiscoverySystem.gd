class_name OdysseyDiscoverySystem
extends Node
signal discovered(id)
var discovered_locations: Dictionary = {}
var revealed_map_regions: Dictionary = {}
func discover(id: String, region: String = "") -> void:
	if discovered_locations.has(id): return
	discovered_locations[id] = Time.get_ticks_msec()
	if region != "": revealed_map_regions[region] = true
	discovered.emit(id)
func is_discovered(id: String) -> bool:
	return discovered_locations.has(id)
func can_fast_travel_to(id: String) -> bool:
	return is_discovered(id)
