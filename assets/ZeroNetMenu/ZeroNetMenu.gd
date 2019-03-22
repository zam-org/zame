extends Control

# screen numbers

# 0 menu
# 1 register
# 2 profile
# 3 login

var current_screen : = 0
var screens : Array

var logged_in : = false setget set_logged_in


func _ready():
	screens.append($anchor/Background/MarginContainer/List/Menu)
	screens.append($anchor/Background/MarginContainer/List/Register)
	screens.append($anchor/Background/MarginContainer/List/Profile)
	screens.append($anchor/Background/MarginContainer/List/Login)
	update_close_button()
	self.logged_in = true
	
	
func appear() -> void:
	if current_screen != 0:
		toggle_screen()
	visible = true
	
	
func disappear() -> void:
	toggle_screen()
	visible = false
	
	
func _on_BackDrop2_gui_input(event) -> void:
	if event is InputEventMouseButton:
		disappear()
	
	
func _on_Close_pressed():
	if current_screen == 0:
		disappear()
	else:
		toggle_screen()
	
	
func update_close_button() -> void:
	if current_screen == 0:
		$anchor/Background/Bot/Close.text = "CLOSE"
	else:
		$anchor/Background/Bot/Close.text = "BACK"
	match current_screen:
		0:
			$anchor/Background/Bot/Button.visible = false
		1:
			$anchor/Background/Bot/Button.text = "REGISTER"
			$anchor/Background/Bot/Button.visible = true
		2:
			$anchor/Background/Bot/Button.visible = false
		3:
			$anchor/Background/Bot/Button.text = "LOG IN"
			$anchor/Background/Bot/Button.visible = true
		
		
func set_logged_in(new : bool) -> void:
	logged_in = new
	
	var text : String
	var status_text : String
	if logged_in:
		$anchor/Background/MarginContainer/List/Menu/Profile.visible = true
		text = "LOG OUT"
		status_text = "CONNECTED"
	else:
		$anchor/Background/MarginContainer/List/Menu/Profile.visible = false
		text = "LOG IN"
		status_text = "OFFLINE"
	$anchor/Background/MarginContainer/List/Menu/Login.text = text
	$anchor/Background/MarginContainer/List/Top/HBoxContainer/Status.text = status_text
		
		
func toggle_screen(new_screen : int = 0) -> void:
	current_screen = new_screen
	for i in screens:
		i.visible = false
	screens[current_screen].visible = true
	update_close_button()
	
	
func _on_Register_pressed():
	toggle_screen(1)
	
	
func _on_Login_pressed():
	if !logged_in:
		toggle_screen(3)
	else:
		self.logged_in = false
		
	
func _on_Profile_pressed():
	toggle_screen(2)
	
	
func _on_Button_pressed():
	if current_screen == 3:
		self.logged_in = true
	
	
func _on_ZeroNet_clicked():
	appear()
	
	

func _on_Copy_pressed():
	OS.clipboard = $anchor/Background/MarginContainer/List/Profile/masterseed.text
