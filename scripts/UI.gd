extends CanvasLayer

var global_mouse_pos : Vector2
var cam_pos : Vector2

var toolbar_orig_pos : Vector2

var play : bool = false
var details_on : bool = false
var hidden_tools : bool = false

var center_label_offset : Vector2 = Vector2(20,20)

var coordinates_centered : bool = false setget set_coordinates_centered
var axis_lines : bool = false setget set_axis_lines

var config_file_path : String = "user://config.cfg"

func _ready():
	#load editor settings
	set_axis_lines(globals.axis_lines)
	set_coordinates_centered(globals.coordinates_centered)
	
	toolbar_orig_pos = $ItemList.rect_position
	$Esc.visible = false
	set_process_input(false)

func _input(event):
	if event is InputEventKey:
		match event.as_text():
			"Escape":
				get_tree().call_group("play", "deactivate")
		
func opacity(on : bool = false):
	$ItemList.visible = on

func activate():
	set_process_input(true)
	play = true
	$ItemList.visible = false
	$Esc.visible = true
	$Lines.visible = false
	$ZoomContainer.visible = false
	
	if $Details.visible:
		details_on = true
		$Details.visible = false
	
func deactivate():
	set_process_input(false)
	play = false
	$ItemList.visible = true
	$Esc.visible = false
	$Lines.visible = true
	$ZoomContainer.visible = true
	
	if details_on:
		$Details.visible = true
		details_on = false


func _on_Upload_pressed():
	$PublishLevelPopUp.visible = true

func _process(delta):
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()

	lines(mouse_pos)
	
	# move the hide toggle button and it's background with the mouse
	# only the the Y axis though
	$ItemList/HideShow.rect_position.y = mouse_pos.y - $ItemList/HideShow.rect_size.y / 2

# move the lines according to the mouse's X and Y
# this happens in the local coordinate system of the 
# viewport
func lines(MousePos : Vector2 = Vector2()):
	$Lines/X.rect_position.x = MousePos.x
	$Lines/Y.rect_position.y = MousePos.y
	
	match globals.coordinates_centered:
		true:
			$Lines/Centered.rect_position = MousePos + center_label_offset
			$Lines/Centered/V/YAmount.text = "Y: " + str(ceil(global_mouse_pos.y * -1))
			$Lines/Centered/V/XAmount.text = "X: " + str(ceil(global_mouse_pos.x))			
		false:
			# update the labels' text for X and Y if we're showing them
			$Lines/Y/YAmount.text = "Y: " + str(ceil(global_mouse_pos.y * -1))
			$Lines/X/XAmount.text = "X: " + str(ceil(global_mouse_pos.x))

func set_coordinates_centered(new):
	coordinates_centered = new
	save_setting("editor", "coordinates_centered", new)
	if new:
		$Lines/X/XAmount.visible = false
		$Lines/Y/YAmount.visible = false
		$Lines/Centered.visible = true
	else:
		$Lines/X/XAmount.visible = true
		$Lines/Y/YAmount.visible = true
		$Lines/Centered.visible = false

func set_axis_lines(new):
	axis_lines = new
	save_setting("editor", "axis_lines", new)
	if !new:
		$Lines/X.visible = false
		$Lines/Y.visible = false
	else:
		$Lines/X.visible = true
		$Lines/Y.visible = true

func save_setting(section, key, value) -> void:
	var conf = ConfigFile.new()
	var err = conf.load(config_file_path)
	conf.set_value(section, key, value)
	conf.save(config_file_path)

func load_setting(section, key, default_value):
	var conf = ConfigFile.new()
	var err = conf.load(config_file_path)
	if err == OK:
		var value = conf.get_value(section, key, default_value)
		return value
	# return the default value should the config file not yet exist
	else:
		return default_value

func _on_level_block_built():
	$Tween.interpolate_property($Lines, "modulate", Color(1,0.64,0.1,0.9), Color(1,1,1,0.4), 1, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
	$Tween.start()


func _on_Camera_cam_pos(pos, mouse_pos):
	cam_pos = pos
	global_mouse_pos = mouse_pos


func _on_HideShowButton_pressed():
	var hidden_pos : Vector2 = Vector2(toolbar_orig_pos.x - $ItemList.rect_size.x, toolbar_orig_pos.y)
	if !hidden_tools:
		$Tween.interpolate_property($ItemList, "rect_position", toolbar_orig_pos, hidden_pos, 0.7, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
		$ItemList/HideShow/HideShowButton.text = ">"
		hidden_tools = true
		
	else:
		$Tween.interpolate_property($ItemList, "rect_position", hidden_pos, toolbar_orig_pos, 0.7, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
		$ItemList/HideShow/HideShowButton.text = "<"
		hidden_tools = false
		
	$Tween.start()


func _on_MagnifyingGlassPlus_pressed():
	$ZoomContainer/CenterContainer/MagnifyAmount.value += $ZoomContainer/CenterContainer/MagnifyAmount.step


func _on_MagnifyingGlassMinus_pressed():
	$ZoomContainer/CenterContainer/MagnifyAmount.value -= $ZoomContainer/CenterContainer/MagnifyAmount.step

