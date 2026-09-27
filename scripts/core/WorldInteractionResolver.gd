class_name OdysseyWorldInteractionResolver
extends Node

func available_actions(target: OdysseyWorldObject) -> Array[String]:
	if target == null:
		return []
	return target.tags.duplicate()

func can_use_environmentally(target: OdysseyWorldObject, action: String) -> bool:
	return target != null and target.can(action)

func resolve(actor: Node, target: OdysseyWorldObject, action: String, strength := 10.0) -> Dictionary:
	if target == null:
		return {"ok": false, "reason": "No target"}
	if not target.can(action):
		return {"ok": false, "reason": "Unsupported action"}
	if action == "break":
		target.apply_damage(strength)
	return {"ok": true, "action": action, "target": target.name}
