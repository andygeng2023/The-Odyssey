class_name OdysseySupabaseClient
extends Node
signal request_completed(result)
signal request_failed(error)
@export var supabase_url := ""
@export var anon_key := ""
func configure(url: String, key: String) -> void:
	supabase_url = url.trim_suffix("/")
	anon_key = key
func is_configured() -> bool:
	return not supabase_url.is_empty() and not anon_key.is_empty()
func select_rows(table: String, query := "") -> void:
	if not is_configured():
		request_failed.emit("Supabase is not configured")
		return
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed.bind(http))
	var url := supabase_url + "/rest/v1/" + table
	if not query.is_empty(): url += "?" + query
	var headers := PackedStringArray(["apikey: " + anon_key, "Authorization: Bearer " + anon_key, "Accept: application/json"])
	var err := http.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		http.queue_free()
		request_failed.emit("HTTP request failed: %s" % err)
func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		request_failed.emit({"result": result, "status": response_code, "body": body.get_string_from_utf8()})
		return
	request_completed.emit(JSON.parse_string(body.get_string_from_utf8()))
