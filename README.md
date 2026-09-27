# The Odyssey — Engine Foundation

Godot 4.x foundation for an emergent, physically-inspired open-world Odyssey.

Implemented systems:
- Capability-based world objects and interactions.
- Bulk-material inventory with limited equipment capacity.
- Data-driven crafting for raft, bridge, ladder, campfire and storage.
- Stamina-driven traversal foundation.
- Weather and sea-state model.
- Discovery-gated map and fast travel.
- Basic Odysseus player actor.

Run with Godot 4.x and open `scenes/Main.tscn`.

This is the engine foundation, not the finished world. Next layers should add physics-aware manipulation, construction placement, climbing surfaces, swimming volumes, vessels, combat, wildlife/AI, save/load, world streaming, underwater traversal, mythological realms, and the Troy-to-shore opening sequence.

The architecture is deliberately capability-based: objects advertise what can be done to them, while systems validate and apply actions. This supports multiple physical solutions to the same problem rather than quest-specific interactions.
