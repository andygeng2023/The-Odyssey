class_name OdysseySupabaseClient
extends Node
signal request_completed(result)
signal request_failed(error)
@export var supabase_url := ""
@export var anon_key := ""
var access_token := ""

func configure(url: String, key: String) -> void:
	supabase_url = url.trim_suffix("/")
	anon_key = key

func set_access_token(token: String) -> void:
	access_token = token

func is_configured() -> bool:
	return not supabase_url.is_empty() and not anon_key.is_empty()

func _headers(prefer := "") -> PackedStringArray:
	var auth := access_token if not access_token.is_empty() else anon_key
	var result := PackedStringArray([
		"apikey: " + anon_key,
		"Authorization: Bearer " + auth,
		"Accept: application/json",
		"Content-Type: application/json"
	])
	if not prefer.is_empty():
		result.append("Prefer: " + prefer)
	return result

func select_rows(table: String, query := "") -> void:
	if not is_configured():
		request_failed.emit("Supabase is not configured")
		return
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed.bind(http))
	var url := supabase_url + "/rest/v1/" + table
	if not query.is_empty(): url += "?" + query
	var err := http.request(url, _headers(), HTTPClient.METHOD_GET)
	if err != OK:
		http.queue_free()
		request_failed.emit("HTTP request failed: %s" % err)

func load_world_state(user_id: String) -> void:
	select_rows("player_world_state", "player_id=eq." + user_id + "&limit=1")

func save_world_state(user_id: String, state: Dictionary) -> void:
	if not is_configured() or access_token.is_empty():
		request_failed.emit("Authenticated Supabase access is required")
		return
	var payload := state.duplicate(true)
	payload["player_id"] = user_id
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed.bind(http))
	var url := supabase_url + "/rest/v1/player_world_state?on_conflict=player_id"
	var body := JSON.stringify(payload)
	var err := http.request(url, _headers("resolution=merge-duplicates,return=representation"), HTTPClient.METHOD_POST, body)
	if err != OK:
		http.queue_free()
		request_failed.emit("HTTP request failed: %s" % err)

func _on_request_completed(result: int, response_code: int, _headers_in: PackedStringArray, body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		request_failed.emit({"result": result, "status": response_code, "body": body.get_string_from_utf8()})
		return
	request_completed.emit(JSON.parse_string(body.get_string_from_utf8()))
