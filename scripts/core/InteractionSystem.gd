class_name OdysseyInteractionSystem
extends Node
signal interaction_succeeded(actor, target, action)
signal interaction_failed(actor, target, action, reason)
func try_action(actor: Node, target: OdysseyWorldObject, action: String) -> bool:
	if target == null or not target.can(action):
		interaction_failed.emit(actor, target, action, "Action not supported")
		return false
	if action == "carry" and not target.carryable:
		interaction_failed.emit(actor, target, action, "Object is not carryable")
		return false
	if action == "break" and not target.breakable:
		interaction_failed.emit(actor, target, action, "Object is not breakable")
		return false
	interaction_succeeded.emit(actor, target, action)
	return true
