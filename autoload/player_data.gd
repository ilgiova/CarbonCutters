extends Node

const SUPABASE_URL = "https://lpnkijkcfczhgwxaasjx.supabase.co"  
const SUPABASE_KEY = "sb_publishable_dX1K20vPAErmuZE0qALbgw_DuxCmePZ"                  # ← la tua anon key

# ============================================================
# DATI ESISTENTI (invariati)
# ============================================================
var score := 0
var cardboardCount: int = 0
var glassCount: int = 0
var aluminumCount: int = 0
var plasticCount: int = 0
var organicCount: int = 0
var current_context: String = "lobby"
var gameAlreadyStarted: bool = false

# ============================================================
# STATO LOGIN
# ============================================================
var is_logged_in: bool = false
var current_user: String = ""

# ============================================================
# SEGNALI
# ============================================================
signal login_success
signal login_failed(reason: String)
signal signup_success
signal signup_failed(reason: String)
signal save_success
signal save_failed(reason: String)


# ============================================================
# AVVIO
# ============================================================
func _ready() -> void:
	TranslationServer.set_locale("en")


# ============================================================
# FUNZIONI ESISTENTI (invariate)
# ============================================================
func add_score(points: int):
	score += points

func get_score():
	return score
	
func getUserName() -> String:
	return current_user
	
func isLoggedIn() -> bool:
	return is_logged_in

func getGameAlreadyStarted() -> bool:
	return gameAlreadyStarted

func setGameAlreadyStarted(status) -> void:
	gameAlreadyStarted = status

func addItem(itemType: int) -> void:
	match itemType:
		0:
			plasticCount += 1
		1:
			cardboardCount += 1
		2:
			glassCount += 1
		3:
			aluminumCount += 1
		4:
			organicCount += 1

func resetData() -> void:
	plasticCount = 0
	cardboardCount = 0
	glassCount = 0
	aluminumCount = 0
	organicCount = 0
	score = 0

func getCardboardCount():
	return cardboardCount

func getGlassCount():
	return glassCount

func getAluminumCount():
	return aluminumCount

func getPlasticCount():
	return plasticCount

func getOrganicCount():
	return organicCount


func signup(username: String, password: String) -> void:
	if username.length() < 5:
		signup_failed.emit("SHORT_USERNAME")
		return
	if password.length() < 8:
		signup_failed.emit("SHORT_PASSWORD")
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

func _on_signup_response(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray, username: String, http: HTTPRequest) -> void:
	http.queue_free()
	
	if response_code == 201:
		current_user = username
		is_logged_in = true
		# resetta i contatori in memoria — siamo un nuovo utente
		resetData()
		signup_success.emit()
	elif response_code == 409:
		signup_failed.emit("Username già esistente")
	else:
		signup_failed.emit("Errore: " + str(response_code))


# ============================================================
# LOGIN
# ============================================================
func login(username: String, password: String) -> void:
	if username.is_empty() or password.is_empty():
		login_failed.emit("Inserisci username e password")
		return
	
	var hashed = _hash_password(password)
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
	cardboardCount = user_data.cardboard_count
	glassCount = user_data.glass_count
	aluminumCount = user_data.aluminum_count
	plasticCount = user_data.plastic_count
	organicCount = user_data.organic_count
	is_logged_in = true
	login_success.emit()


# ============================================================
# SALVATAGGIO REMOTO
# ============================================================
func save_data() -> void:
	if not is_logged_in:
		# Se non sei loggato, niente salvataggio remoto
		return
	
	var url = SUPABASE_URL + "/rest/v1/users?name=eq." + current_user
	
	var headers = [
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY,
		"Content-Type: application/json"
	]
	
	var body = JSON.stringify({
		"score": score,
		"cardboard_count": cardboardCount,
		"glass_count": glassCount,
		"aluminum_count": aluminumCount,
		"plastic_count": plasticCount,
		"organic_count": organicCount,
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


# ============================================================
# LOGOUT
# ============================================================
func logout() -> void:
	if is_logged_in:
		save_data()
	is_logged_in = false
	current_user = ""
	resetData()


# ============================================================
# UTILITY
# ============================================================
func _hash_password(password: String) -> String:
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(password.to_utf8_buffer())
	var hash_bytes = ctx.finish()
	return hash_bytes.hex_encode()
