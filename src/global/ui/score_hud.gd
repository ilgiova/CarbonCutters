extends CanvasLayer

@onready var label = $MarginContainer2/Label
@onready var foodLabel: Label = $MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var cardBoardLabel: Label = $MarginContainer/VBoxContainer/HBoxContainer2/Label
@onready var waterLabel: Label = $MarginContainer/VBoxContainer/HBoxContainer3/Label
@onready var glassLabel: Label = $MarginContainer/VBoxContainer/HBoxContainer4/Label
@onready var canLabel: Label = $MarginContainer/VBoxContainer/HBoxContainer5/Label
@onready var trashDisplay: MarginContainer = $MarginContainer

func _process(_delta):
	label.text = tr("SCORE")+": " + str(PlayerData.score)
	foodLabel.text = str(PlayerData.getOrganicCount())
	cardBoardLabel.text = str(PlayerData.getCardboardCount())
	waterLabel.text = str(PlayerData.getPlasticCount())
	glassLabel.text = str(PlayerData.getGlassCount())
	canLabel.text = str(PlayerData.getAluminumCount())
	if PlayerData.current_context == "lobby":
		trashDisplay.visible = true
	else:
		trashDisplay.visible = false
	
