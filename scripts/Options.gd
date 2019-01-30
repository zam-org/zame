extends Control

var hello : = ""

func _ready():
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.add_item("OFF")
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.add_item("2x")
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.add_item("4x")
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.add_item("8x")
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.add_item("16x")
	
	update_values()
	
func update_values() -> void:
	#set the values according to current settings
	$OptionsColor/Window/OptionsFrame/Buttons/CenterContainer2/Vsync.pressed = ProjectSettings.get("display/window/vsync/use_vsync")
	$OptionsColor/Window/OptionsFrame/Buttons/CenterContainer/Fullscreen.pressed = OS.window_fullscreen
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.select(ProjectSettings.get("rendering/quality/filters/msaa"))
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer2/Anisotropic_level.value = ProjectSettings.get("rendering/quality/filters/anisotropic_filter_level")

func _on_Fullscreen_toggled(button_pressed) -> void:
	print("fullscreen ", button_pressed)
	OS.window_fullscreen = button_pressed
	show_saved()	

func _on_MSAA_item_selected(ID) -> void:
	ProjectSettings.set("rendering/quality/filters/msaa", ID)
	print("New MSAA setting: ", ProjectSettings.get("rendering/quality/filters/msaa"))
	show_saved()

func _on_Vsync_toggled(button_pressed) -> void:
	ProjectSettings.set("display/window/vsync/use_vsync", button_pressed)
	print("Vsync: ", ProjectSettings.get("display/window/vsync/use_vsync"))
	show_saved()	
	
func _on_Anisotropic_level_value_changed(value):
	ProjectSettings.set("rendering/quality/filters/anisotropic_filter_level", value)
	print("New Anisotropic level setting: ", ProjectSettings.get("rendering/quality/filters/anisotropic_filter_level"))
	show_saved()

func _on_ColorRect_gui_input(event):
	if event is InputEventMouseButton:
		visible = false
		
func show_saved() -> void:
	$Tween.interpolate_property($OptionsColor/Window/saved, "modulate", Color(1,1,1,1), Color(1,1,1,0), 3, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.start()