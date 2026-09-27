class_name OdysseyWorldFeatureRegistry
extends Node

const FEATURES := {
    "gathering": "Gather wood, stone, food, herbs and rare materials.",
    "crafting": "Turn materials into tools, meals, weapons, boats and camp equipment.",
    "construction": "Build bridges, shelters, ladders, docks and improvised structures.",
    "physics": "Move, carry, push, pull, burn, cut and combine the physical world.",
    "climbing": "Climb cliffs, ruins, trees and constructed surfaces.",
    "swimming": "Swim, dive and explore submerged locations.",
    "transport": "Use rafts, ships, carts and other discovered transport.",
    "survival": "Manage warmth, food, fatigue, weather and safe camp preparation.",
    "cities": "Visit Greek settlements with merchants, craftsmen, sailors and quests.",
    "wildlife": "Track, avoid, observe and interact with animals and ecosystems.",
    "mythology": "Encounter gods, monsters, sacred places and mythic consequences.",
    "underwater": "Explore reefs, wrecks, caves and submerged ruins.",
    "underworld": "Enter a dangerous realm tied to the dead and the journey home.",
    "heavens": "Reach mythic high places and divine domains.",
    "calypso": "Discover Calypso's island and its story arc.",
    "fast_travel": "Unlock discovered destinations rather than receiving them automatically.",
    "relationships": "Build trust, rivalry and alliances that alter available solutions.",
    "ithaca": "Return to Ithaca and resolve the homecoming.",
    "generations": "See a post-homecoming epilogue shaped by the journey."
}

func has_feature(id: String) -> bool:
    return FEATURES.has(id)

func all_features() -> Dictionary:
    return FEATURES.duplicate(true)
