extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(false)	
	visible = false

func _input(event):
	if event is InputEventKey:

		if event.scancode == OS.find_scancode_from_string("ESCAPE") and event.pressed:
			set_process_input(false)			
			visible = false
			$Menu/No.emit_signal("pressed")

		elif event.scancode == OS.find_scancode_from_string("ENTER") and event.pressed:
			set_process_input(false)
			visible = false
			$Menu/Yes.emit_signal("pressed")

func pop_up(message : String = "", no : String = "", yes : String = "") -> void:
	set_process_input(true)
	if message != "":
		$Window/TextContainer/Text.text = message
	if no != "":
		$Window/Buttons/Menu/No.text = no
	if yes != "":
		$Window/Buttons/Menu/Yes.text = yes
	
	self.visible = true

func _on_No_pressed() -> void:
	set_process_input(false)
	visible = false

func _on_Yes_pressed() -> void:
	set_process_input(false)
	visible = false

func _on_Black_gui_input(event):
	if event is InputEventMouseButton:
		visible = false
		$Window/Buttons/Menu/No.emit_signal("pressed")
		set_process_input(false)
		