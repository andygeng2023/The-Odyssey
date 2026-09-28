class_name OdysseyRealmSystem
extends Node

signal realm_entered(id)
var active_realm := "aegean"
var realms := {
    "aegean": {"name":"Aegean Coast", "depth":0},
    "underwater": {"name":"Sunken Realms", "depth":-1},
    "underworld": {"name":"Underworld", "depth":-2},
    "heavens": {"name":"Heavens", "depth":2},
    "calypso": {"name":"Calypso's Island", "depth":0}
}

func enter(id: String) -> bool:
    if not realms.has(id):
        return false
    active_realm = id
    realm_entered.emit(id)
    return true

func display_name() -> String:
    return str(realms.get(active_realm, {}).get("name", "Aegean Coast"))
