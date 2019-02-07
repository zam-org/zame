extends Control

var config_file_path : String = "user://config.cfg"
var resizing : bool = false

onready var map_list : ItemList = $SidePanelSpace/SidePanel/MapList

const MIN_MAP_LIST_SIZE = 95

func _ready():
	set_process_input(false)
	map_list.rect_min_size.y = load_setting("main_menu", "map_list_length", 139)
	map_list.select(load_setting("main_menu", "selected_map", 0))
	
	if map_list.rect_min_size.y > OS.window_size.y / 2.2:
		map_list.rect_min_size.y = MIN_MAP_LIST_SIZE
		
	$SidePanelSpace/SidePanel/MapList.update_maps()

func _input(event):
	if event is InputEventMouseButton:
		# show mouse and stop listening to input when LMB is unclicked
		if event.button_index == 1 and !event.pressed:
			set_process_input(false)
			# save the length of the box into our config file
			save_setting("main_menu", "map_list_length", map_list.rect_min_size.y)
			Input.set_mouse_mode(0)
			var new_mouse_pos = $SidePanelSpace/SidePanel/grab_container/GrabMe.rect_global_position
			new_mouse_pos.x += $SidePanelSpace/SidePanel/grab_container/GrabMe.rect_size.x / 2
			new_mouse_pos.y += $SidePanelSpace/SidePanel/grab_container/GrabMe.rect_size.y / 2
			Input.warp_mouse_position(new_mouse_pos)
			resizing = false
	elif event is InputEventMouseMotion:
		# listen to mouse speed and apply it to the rectangle size
		# ONLY if the change in size is within limits
		var change = event.relative.y
		if map_list.rect_min_size.y + change < OS.window_size.y / 2.2 and map_list.rect_min_size.y + change > MIN_MAP_LIST_SIZE:
			map_list.rect_min_size.y += change
			$SidePanelSpace/SidePanel.queue_sort()
			play_knob_turn()

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

func _on_grab_me_pressed() -> void:
	resizing = true
	set_process_input(true)
	Input.set_mouse_mode(2)

func play_click() -> void:
	$audio/click.play()

func play_knob_turn() -> void:
	$audio/knob.play()

func _on_MapList_item_selected(index):
	play_click()
	save_setting("main_menu", "selected_map", index)

func _on_zn_button_pressed():
	OS.shell_open("https://zeronet.io")

func _on_play_pressed():
	get_tree().change_scene("res://scenes/default.tscn")

func _on_config_pressed():
	$Options.set_process(true)
	$Options.visible = true

func _connect_to_zame():
	# ZAME site address
	var site_address = "1LX49GcJ52xF8UGvN1obXex6u4XLwfmzZW"

	# Open a connection to a ZeroNet site
	if not yield(ZeroFrame.use_site(site_address), "site_connected"):
    	print("Unable to connect to site")
    	return

func _on_Exit_pressed():
	get_tree().quit()

func _on_Update_pressed():
	_connect_to_zame()
