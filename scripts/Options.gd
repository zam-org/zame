extends Control

const config_file_path : = "user://config.cfg"

func _ready():
	self.visible = false
	
	# add items tp
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.add_item("OFF")
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.add_item("2x")
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.add_item("4x")
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.add_item("8x")
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.add_item("16x")
	
	#	update the game according to settings
	OS.window_borderless = load_setting("settings", "borderless", true)
	OS.window_fullscreen = load_setting("settings", "fullscreen", false)
	OS.window_resizable = load_setting("settings", "resizable", false)
	OS.vsync_enabled = load_setting("settings", "vsync", true)
	VisualServer.viewport_set_msaa(get_viewport().get_viewport_rid(), load_setting("settings", "MSAA", 3))
	ProjectSettings.set("rendering/quality/filters/anisotropic_filter_level", load_setting("settings", "anisotropic_level", 4))
	
	update_values()
	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_parent().play_click()
		self.visible = false
		set_process(false)
	
func update_values() -> void:
	#set the values according to current settings
	$OptionsColor/Window/OptionsFrame/Buttons/CenterContainer2/Vsync.pressed = ProjectSettings.get("display/window/vsync/use_vsync")
	$OptionsColor/Window/OptionsFrame/Buttons/CenterContainer/Fullscreen.pressed = OS.window_fullscreen
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer/MSAA.select(ProjectSettings.get("rendering/quality/filters/msaa"))
	$OptionsColor/Window/OptionsFrame/Buttons/HBoxContainer2/Anisotropic_level.value = ProjectSettings.get("rendering/quality/filters/anisotropic_filter_level")
	$OptionsColor/Window/OptionsFrame/Buttons/CenterContainer3/Borderless.pressed = load_setting("settings", "borderless", true)
	$OptionsColor/Window/OptionsFrame/Buttons/CenterContainer4/Resizable.pressed = OS.window_resizable

func _on_Fullscreen_toggled(button_pressed) -> void:
	print("fullscreen ", button_pressed)
	OS.window_fullscreen = button_pressed
	save_setting("settings", "fullscreen", button_pressed)
	show_saved()	

func _on_MSAA_item_selected(ID) -> void:
	ProjectSettings.set("rendering/quality/filters/msaa", ID)
	print("New MSAA setting: ", ProjectSettings.get("rendering/quality/filters/msaa"))
	save_setting("settings", "MSAA", ID)	
	VisualServer.viewport_set_msaa(get_viewport().get_viewport_rid(), ID)
	globals.MSAA = ID
	show_saved()

func _on_Vsync_toggled(button_pressed) -> void:
	ProjectSettings.set("display/window/vsync/use_vsync", button_pressed)
	OS.vsync_enabled = button_pressed
	print("Vsync: ", OS.vsync_enabled)
	save_setting("settings", "vsync", button_pressed)	
	show_saved()	
	
func _on_Borderless_toggled(button_pressed):
	ProjectSettings.set("display/window/size/borderless", button_pressed)
	OS.window_borderless = button_pressed
	print("Borderless: ", ProjectSettings.get("display/window/size/borderless"))
	save_setting("settings", "borderless", button_pressed)	
	show_saved()	
	
func _on_Resizable_toggled(button_pressed):
	OS.window_resizable = button_pressed
	save_setting("settings", "resizable", button_pressed)	
	print("Window resizable: ", button_pressed)
	
func _on_Anisotropic_level_value_changed(value):
	ProjectSettings.set("rendering/quality/filters/anisotropic_filter_level", value)
	print("New Anisotropic level setting: ", ProjectSettings.get("rendering/quality/filters/anisotropic_filter_level"))
	save_setting("settings", "anisotropic_level", value)
	show_saved()

func _on_ColorRect_gui_input(event):
	if event is InputEventMouseButton:
		visible = false
		get_parent().play_click()
		
func show_saved() -> void:
	$Tween.interpolate_property($OptionsColor/Window/saved, "modulate", Color(1,1,1,1), Color(1,1,1,0), 2, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
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
