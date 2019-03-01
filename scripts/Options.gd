extends Control

const config_file_path : = "user://config.cfg"

signal saved

func _ready():
	self.visible = false
	
	#if the config file ccanot be loaded, we put in all the default settings
	var conf = ConfigFile.new()
	var err = conf.load(config_file_path)
	if err:
		reset_settings()
	
	# add items tp
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.add_item("OFF")
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.add_item("2x")
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.add_item("4x")
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.add_item("8x")
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.add_item("16x")
	
	#	update the game according to settings
	OS.window_borderless = load_setting("settings", "borderless", false)
	OS.window_fullscreen = load_setting("settings", "fullscreen", false)
	OS.window_resizable = load_setting("settings", "resizable", true)
	OS.vsync_enabled = load_setting("settings", "vsync", true)
	get_viewport().msaa = load_setting("settings", "MSAA", 3)
	ProjectSettings.set("rendering/quality/filters/anisotropic_filter_level", load_setting("settings", "anisotropic_level", 4))
	
	update_values()
	
func update_values() -> void:
	#set the values according to current settings
	$OptionsColor/Window/OptionsFrame/Buttons/CenterContainer2/Vsync.pressed = load_setting("settings", "vsync", true)
	$OptionsColor/Window/OptionsFrame/Buttons/CenterContainer/Fullscreen.pressed = OS.window_fullscreen
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.select(load_setting("settings", "MSAA", 3))
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer2/Anisotropic_level.value = load_setting("settings", "anisotropic_level", 4)
	$OptionsColor/Window/OptionsFrame/Buttons/CenterContainer3/Borderless.pressed = load_setting("settings", "borderless", true)
	$OptionsColor/Window/OptionsFrame/Buttons/CenterContainer4/Resizable.pressed = load_setting("settings", "resizable", true)	
	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_parent().play_click()
		self.visible = false
		set_process(false)
		
	
func _on_Fullscreen_toggled(button_pressed) -> void:
	if $OptionsColor/Window/OptionsFrame/Buttons/CenterContainer3/Borderless.pressed and button_pressed:
		OS.window_borderless = false
		save_setting("settings", "borderless", false)	
		$OptionsColor/Window/OptionsFrame/Buttons/CenterContainer3/Borderless.pressed = false
		
	print("fullscreen ", button_pressed)
	OS.window_fullscreen = button_pressed
	save_setting("settings", "fullscreen", button_pressed)
	
	
func _on_MSAA_item_selected(ID) -> void:
	ProjectSettings.set("rendering/quality/filters/msaa", ID)
	print("New MSAA setting: ", ProjectSettings.get("rendering/quality/filters/msaa"))
	save_setting("settings", "MSAA", ID)	
	VisualServer.viewport_set_msaa(get_viewport().get_viewport_rid(), ID)
	globals.MSAA = ID
	
	
func _on_Vsync_toggled(button_pressed) -> void:
	ProjectSettings.set("display/window/vsync/use_vsync", button_pressed)
	OS.vsync_enabled = button_pressed
	print("Vsync: ", OS.vsync_enabled)
	save_setting("settings", "vsync", button_pressed)	
	
	
func _on_Borderless_toggled(button_pressed):
	if OS.window_fullscreen and button_pressed:
		OS.window_fullscreen = false
		save_setting("settings", "fullscreen", false)	
		$OptionsColor/Window/OptionsFrame/Buttons/CenterContainer/Fullscreen.pressed = false
		
		
	ProjectSettings.set("display/window/size/borderless", button_pressed)
	OS.window_borderless = button_pressed
	print("Borderless: ", ProjectSettings.get("display/window/size/borderless"))
	save_setting("settings", "borderless", button_pressed)	
	
	
func _on_Resizable_toggled(button_pressed):
	OS.window_resizable = button_pressed
	save_setting("settings", "resizable", button_pressed)	
	print("Window resizable: ", button_pressed)
	
	
func _on_Anisotropic_level_value_changed(value):
	ProjectSettings.set("rendering/quality/filters/anisotropic_filter_level", value)
	print("New Anisotropic level setting: ", ProjectSettings.get("rendering/quality/filters/anisotropic_filter_level"))
	save_setting("settings", "anisotropic_level", value)
	
	
func _on_ColorRect_gui_input(event):
	if event is InputEventMouseButton:
		visible = false
		get_parent().play_click()
		set_process(false)
		
		
func show_saved() -> void:
	var saved_pos = Vector2(0,65)
	$OptionsColor/saved.visible_characters = 0
	
	$Tween.interpolate_property($OptionsColor/saved, "rect_position", Vector2(0, saved_pos.y - 40), saved_pos, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.interpolate_property($OptionsColor/saved, "modulate", Color(1,1,1,0), Color(1,1,1,1), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.interpolate_property($OptionsColor/saved, "visible_characters", 0, 5, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.1)

	$Tween.interpolate_property($OptionsColor/saved, "modulate", Color(1,1,1,1), Color(1,1,1,0), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 1)	
	$Tween.interpolate_property($OptionsColor/saved, "rect_position", saved_pos, Vector2(0, saved_pos.y + 40), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 1)
	$Tween.start()
	
	
func load_setting(section, key, default_value):
	var conf = ConfigFile.new()
	var err = conf.load(config_file_path)
	if err == OK:
		var value = conf.get_value(section, key, default_value)
		return value
	# return the default value should the config file not yet exist
	else:
		return default_value
		
		
func save_setting(section, key, value) -> void:
	var conf = ConfigFile.new()
	var err = conf.load(config_file_path)
	conf.set_value(section, key, value)
	conf.save(config_file_path)
	emit_signal("saved")
	
	
func _on_Close_pressed():
	get_parent().play_click()
	self.visible = false
	set_process(false)
	
	
func _on_Defaults_pressed():
	reset_settings()
	
	
func reset_settings() -> void:
	#	reset settings
	save_setting("settings", "vsync", true)
	save_setting("settings", "fullscreen", false)
	save_setting("settings", "MSAA", 3)
	save_setting("settings", "anisotropic_level", 4)
	save_setting("settings", "borderless", false)
	save_setting("settings", "resizable", true)
	
	#	update the game according to settings
	OS.vsync_enabled = load_setting("settings", "vsync", true)
	OS.window_fullscreen = load_setting("settings", "fullscreen", false)
	VisualServer.viewport_set_msaa(get_viewport().get_viewport_rid(), load_setting("settings", "MSAA", 3))
	ProjectSettings.set("rendering/quality/filters/anisotropic_filter_level", load_setting("settings", "anisotropic_level", 4))
	OS.window_borderless = load_setting("settings", "borderless", false)
	OS.window_resizable = load_setting("settings", "resizable", true)
	
	update_values()