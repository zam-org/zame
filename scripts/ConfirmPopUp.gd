extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func pop_up(message : String = "", no : String = "", yes : String = "") -> void:
	if message != "":
		$ColorRect/Label.text = message
	if no != "":
		$HBoxContainer/No.text = no
	if yes != "":
		$HBoxContainer/Yes.text = yes
	
	self.visible = true

func _on_No_pressed() -> void:
	visible = false

func _on_Yes_pressed() -> void:
	visible = false
