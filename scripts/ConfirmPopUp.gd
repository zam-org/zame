extends Control

func _ready():
	set_process_input(false)	
	visible = false

func _input(event):
	if event is InputEventKey:

		if event.scancode == OS.find_scancode_from_string("ESCAPE") and event.pressed:
			set_process_input(false)			
			visible = false
			$Window/Buttons/Menu/No.emit_signal("pressed")

		elif event.scancode == OS.find_scancode_from_string("ENTER") and event.pressed:
			set_process_input(false)
			visible = false
			$Window/Buttons/Menu/Yes.emit_signal("pressed")

func pop_up(message : String = "", no : String = "", yes : String = "", saving : bool = false) -> void:
	set_process_input(true)
	if message != "":
		$Window/TextContainer/Text.text = message
	if no != "":
		$Window/Buttons/Menu/No.text = no
	if yes != "":
		$Window/Buttons/Menu/Yes.text = yes

#	$Window/TextContainer/Text.visible = false if saving else true
	$Window/TextContainer/Margin/Input.visible = true if saving else false
	
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
		
		
func get_input() -> String:
	var map_name = $Window/TextContainer/Margin/Input.text
	return map_name