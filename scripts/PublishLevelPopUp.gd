extends Control

func _ready():
	visible = false
	$Window/Horizontal/TextContainer/Version.text = ProjectSettings.get("application/config/version")
	
	

func _on_Black_gui_input(event):
	if event is InputEventMouseButton:
		visible = false
		$Window/Buttons/Menu/No.emit_signal("pressed")
		
		

func _on_No_pressed():
	visible = false
	
	

func _on_Yes_pressed():
	visible = false
	
	