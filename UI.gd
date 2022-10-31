extends Control

onready var Player = $"../Player"
onready var health : RichTextLabel = $Health
onready var score : RichTextLabel = $Score
onready var menu_button : Button = $MenuButton
onready var game_over : RichTextLabel = $GameOver

# Called when the node enters the scene tree for the first time.
func _ready():
	health.set_text(str(Player.health))
	score.set_text(str(Player.score))

func _process(_delta):
	if str(Player.score) != score.text:
		score.set_text(str(Player.score))
	
	if str(Player.health) != health.text:
		health.set_text(str(Player.health))
		
	if Player.health <= 0:
		game_over.visible = true
		menu_button.visible = true
		menu_button.grab_focus()
	


func _on_MenuButton_pressed():
	get_tree().change_scene("res://MainMenu.tscn")
