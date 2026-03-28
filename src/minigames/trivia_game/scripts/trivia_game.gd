extends Control

@export_file("*.json") var questionsFileEn: String = "res://src/minigames/trivia_game/scripts/TriviaQuestionEn.json"
@export_file("*.json") var questionsFileIt: String = "res://src/minigames/trivia_game/scripts/TriviaQuestionIt.json"

@export var normalButtonTexture: Texture2D
@export var hoverButtonTexture: Texture2D
@export var correctButtonTexture: Texture2D
@export var wrongButtonTexture: Texture2D

var questions: Array = []
var remainingQuestions: Array = []
var currentQuestion: Dictionary = {}
var canAnswer: bool = true

@onready var questionLabel: Label = $MainPanel/QuestionFrame/MarginContainer/VBoxContainer/MarginContainer5/Question

@onready var answer1Label: Label = $MainPanel/QuestionFrame/MarginContainer/VBoxContainer/MarginContainer/anser1
@onready var answer2Label: Label = $MainPanel/QuestionFrame/MarginContainer/VBoxContainer/MarginContainer2/anser2
@onready var answer3Label: Label = $MainPanel/QuestionFrame/MarginContainer/VBoxContainer/MarginContainer3/anser3
@onready var answer4Label: Label = $MainPanel/QuestionFrame/MarginContainer/VBoxContainer/MarginContainer4/anser4

@onready var button1: TextureButton = $MainPanel/QuestionFrame/MarginContainer/VBoxContainer/MarginContainer/button1
@onready var button2: TextureButton = $MainPanel/QuestionFrame/MarginContainer/VBoxContainer/MarginContainer2/button2
@onready var button3: TextureButton = $MainPanel/QuestionFrame/MarginContainer/VBoxContainer/MarginContainer3/button3
@onready var button4: TextureButton = $MainPanel/QuestionFrame/MarginContainer/VBoxContainer/MarginContainer4/button4

func _ready() -> void:
	randomize()
	PlayerData.current_context = "minigame"
	loadQuestions()

	if questions.is_empty():
		print("Nessuna domanda caricata")
		return

	remainingQuestions = questions.duplicate(true)

	button1.pressed.connect(func(): checkAnswer(0))
	button2.pressed.connect(func(): checkAnswer(1))
	button3.pressed.connect(func(): checkAnswer(2))
	button4.pressed.connect(func(): checkAnswer(3))

	showRandomQuestion()


func loadQuestions() -> void:
	var file 
	if TranslationServer.get_locale().begins_with("en"):
		file = FileAccess.open(questionsFileEn, FileAccess.READ)
	else:
		file = FileAccess.open(questionsFileIt, FileAccess.READ)
	if file == null:
		return
		
	var content = file.get_as_text()
	var parsed = JSON.parse_string(content)

	if parsed == null:
		print("JSON non valido")
		return

	if parsed is Array:
		questions = parsed
	elif parsed is Dictionary:
		questions = [parsed]
	else:
		print("Formato JSON non supportato")


func showRandomQuestion() -> void:
	if remainingQuestions.is_empty():
		remainingQuestions = questions.duplicate(true)

	resetButtons()
	setButtonsDisabled(false)
	canAnswer = true

	var randomIndex = randi() % remainingQuestions.size()
	currentQuestion = remainingQuestions[randomIndex]
	remainingQuestions.remove_at(randomIndex)

	questionLabel.text = str(currentQuestion["question"])

	var answers: Array = currentQuestion["answers"]
	answer1Label.text = str(answers[0])
	answer2Label.text = str(answers[1])
	answer3Label.text = str(answers[2])
	answer4Label.text = str(answers[3])


func checkAnswer(selectedIndex: int) -> void:
	if not canAnswer:
		return

	canAnswer = false
	setButtonsDisabled(true)

	var buttons: Array[TextureButton] = [button1, button2, button3, button4]
	var correctIndex: int = int(currentQuestion["correctIndex"])

	if selectedIndex == correctIndex:
		setButtonResultTexture(buttons[selectedIndex], correctButtonTexture)
		PlayerData.add_score(5)
	else:
		setButtonResultTexture(buttons[selectedIndex], wrongButtonTexture)
		setButtonResultTexture(buttons[correctIndex], correctButtonTexture)
		

	await get_tree().create_timer(1.0).timeout
	showRandomQuestion()


func setButtonDefaultTextures(button: TextureButton) -> void:
	button.texture_normal = normalButtonTexture
	button.texture_hover = hoverButtonTexture
	button.texture_disabled = normalButtonTexture


func setButtonResultTexture(button: TextureButton, texture: Texture2D) -> void:
	button.texture_normal = texture
	button.texture_hover = texture
	button.texture_disabled = texture


func resetButtons() -> void:
	setButtonDefaultTextures(button1)
	setButtonDefaultTextures(button2)
	setButtonDefaultTextures(button3)
	setButtonDefaultTextures(button4)


func setButtonsDisabled(disabled: bool) -> void:
	button1.disabled = disabled
	button2.disabled = disabled
	button3.disabled = disabled
	button4.disabled = disabled
