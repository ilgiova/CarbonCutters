extends Node

# ============================================================
# CONFIGURAZIONE — sostituisci con i tuoi dati Supabase
# ============================================================
const SUPABASE_URL = "https://lpnkijkcfczhgwxaasjx.supabase.co"  # ← il tuo Project URL
const SUPABASE_KEY = "sb_publishable_dX1K20vPAErmuZE0qALbgw_DuxCmePZ"                  # ← la tua anon key

# ============================================================
# STATO CORRENTE
# ============================================================
var is_logged_in: bool = false
var is_guest: bool = false
var current_user: String = ""

# Dati del giocatore
var score: int = 0
var cardboard_count: int = 0
var glass_count: int = 0
var aluminum_count: int = 0
var plastic_count: int = 0
var organic_count: int = 0

# ============================================================
# SEGNALI
# ============================================================
signal login_success
signal login_failed(reason: String)
signal signup_success
signal signup_failed(reason: String)
signal save_success
signal save_failed(reason: String)

func _ready() -> void:
	pass


func signup(username: String, password: String) -> void:
	if username.length() < 3:
		signup_failed.emit("Username troppo corto (min 3 caratteri)")
		return
	if password.length() < 4:
		signup_failed.emit("Password troppo corta (min 4 caratteri)")
		return
	
	var hashed = _hash_password(password)
	var url = SUPABASE_URL + "/rest/v1/users"
	
	var headers = [
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY,
		"Content-Type: application/json",
		"Prefer: return=representation"
	]
	
	var body = JSON.stringify({
		"name": username,
		"password_hash": hashed,
		"score": 0,
		"cardboard_count": 0,
		"glass_count": 0,
		"aluminum_count": 0,
		"plastic_count": 0,
		"organic_count": 0
	})
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_signup_response.bind(username, http))
	http.request(url, headers, HTTPClient.METHOD_POST, body)

func _on_signup_response(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, username: String, http: HTTPRequest) -> void:
	http.queue_free()
	
	if response_code == 201:
		current_user = username
		is_logged_in = true
		is_guest = false
		signup_success.emit()
	elif response_code == 409:
		signup_failed.emit("Username già esistente")
	else:
		var _error_msg = body.get_string_from_utf8()
		signup_failed.emit("Errore: " + str(response_code))


func login(username: String, password: String) -> void:
	if username.is_empty() or password.is_empty():
		login_failed.emit("Inserisci username e password")
		return
	
	var hashed = _hash_password(password)
	# Query: cerca user con name=username AND password_hash=hashed
	var url = SUPABASE_URL + "/rest/v1/users?name=eq." + username + "&password_hash=eq." + hashed
	
	var headers = [
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY
	]
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_login_response.bind(http))
	http.request(url, headers, HTTPClient.METHOD_GET)

func _on_login_response(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
	
	if response_code != 200:
		login_failed.emit("Errore di rete (code " + str(response_code) + ")")
		return
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null or json.size() == 0:
		login_failed.emit("Username o password errati")
		return
	
	var user_data = json[0]
	current_user = user_data.name
	score = user_data.score
	cardboard_count = user_data.cardboard_count
	glass_count = user_data.glass_count
	aluminum_count = user_data.aluminum_count
	plastic_count = user_data.plastic_count
	organic_count = user_data.organic_count
	is_logged_in = true
	is_guest = false
	login_success.emit()


func login_as_guest() -> void:
	is_guest = true
	is_logged_in = false
	current_user = tr("GUEST")
	# Carica dati locali se esistono
	_load_local_data()


func save_data() -> void:
	if is_guest:
		_save_local_data()
		save_success.emit()
	elif is_logged_in:
		_save_remote_data()
	else:
		save_failed.emit("Non sei loggato")

func _save_remote_data() -> void:
	var url = SUPABASE_URL + "/rest/v1/users?name=eq." + current_user
	
	var headers = [
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY,
		"Content-Type: application/json"
	]
	
	var body = JSON.stringify({
		"score": score,
		"cardboard_count": cardboard_count,
		"glass_count": glass_count,
		"aluminum_count": aluminum_count,
		"plastic_count": plastic_count,
		"organic_count": organic_count,
		"updated_at": Time.get_datetime_string_from_system()
	})
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_save_response.bind(http))
	http.request(url, headers, HTTPClient.METHOD_PATCH, body)

func _on_save_response(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
	if response_code == 200 or response_code == 204:
		save_success.emit()
	else:
		save_failed.emit("Errore salvataggio: " + str(response_code))


func _save_local_data() -> void:
	var data = {
		"score": score,
		"cardboard_count": cardboard_count,
		"glass_count": glass_count,
		"aluminum_count": aluminum_count,
		"plastic_count": plastic_count,
		"organic_count": organic_count
	}
	var file = FileAccess.open("user://guest_data.save", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func _load_local_data() -> void:
	if not FileAccess.file_exists("user://guest_data.save"):
		return
	var file = FileAccess.open("user://guest_data.save", FileAccess.READ)
	if file == null:
		return
	var content = file.get_as_text()
	file.close()
	var data = JSON.parse_string(content)
	if data == null:
		return
	score = data.get("score", 0)
	cardboard_count = data.get("cardboard_count", 0)
	glass_count = data.get("glass_count", 0)
	aluminum_count = data.get("aluminum_count", 0)
	plastic_count = data.get("plastic_count", 0)
	organic_count = data.get("organic_count", 0)


func logout() -> void:
	if is_logged_in:
		save_data()  # salva prima di sloggare
	is_logged_in = false
	is_guest = false
	current_user = ""
	_reset_data()

func _reset_data() -> void:
	score = 0
	cardboard_count = 0
	glass_count = 0
	aluminum_count = 0
	plastic_count = 0
	organic_count = 0


func _hash_password(password: String) -> String:
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(password.to_utf8_buffer())
	var hash_bytes = ctx.finish()
	return hash_bytes.hex_encode()
