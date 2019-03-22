extends Control

# map related settings
var maps : = []

signal double_clicked_map

# level browser settings
var m_y : float
const MIN_SIZE : float = 620.0

var orig_x : float

func _ready() -> void:
	set_process_input(false)
	
func _input(event):
	if event is InputEventMouseMotion:
		m_y = event.relative.y
		if $VBoxContainer/BotPanel.rect_min_size.y - m_y > MIN_SIZE && $VBoxContainer.rect_min_size.y - m_y < OS.get_real_window_size().y:
			$VBoxContainer/BotPanel.rect_min_size.y -= m_y
			$VBoxContainer.rect_min_size.y -= m_y
			$VBoxContainer.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
			
	if event is InputEventMouseButton:
		if event.button_index == 1 and !event.pressed:
			Input.warp_mouse_position($VBoxContainer/TopPanel/HBoxContainer2/Size.rect_position + rect_position)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			set_process_input(false)

func disappear() -> void:
	visible = false

func appear() -> void:
	visible = true
	update_maps_local()

func _on_Size_button_down() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(true)

func _on_Close_pressed() -> void:
	disappear()

## levels

func update_maps_local() -> void:
	var maps = $VBoxContainer/BotPanel/MapBrowse/MarginContainer/Maps
	maps.clear()	
	var dir = Directory.new()
	var err = dir.open(globals.level_path)
	if err:
		print("Error encountered opening the maps directory. This should not have happened. Please stand up and dance circles around your chair till the problem is fixed.")
		return
		
	dir.list_dir_begin(true, false)
	var file_name = dir.get_next()
	while (file_name != ""):
		print(file_name)
		file_name = dir.get_next()
		if file_name.ends_with(".tscn") and file_name != "temp.tscn":
			maps.add_item(file_name.trim_suffix(".tscn"))
#		print("Found map: " + file_name)
#			maps.append(file_name.trim_suffix(".tscn"))
#			add_item(maps[-1])
#		dir.get_next()
		
	dir.list_dir_end()
	print(maps)


func update_maps_zn() -> void:
	var maps = $VBoxContainer/BotPanel/MapBrowse/MarginContainer/Maps
	maps.clear()

#func _on_MapList_item_selected(index):
#	globals.map = get_item_text(index)
#	print(globals.map)
#
#
#func _on_MapList_item_activated(index):
#	emit_signal("double_clicked_map")


func _on_Browser_pressed() -> void:
	appear()


func _on_Blur_gui_input(event) -> void:
	if event is InputEventMouseButton:
		disappear()


func _on_Local_pressed() -> void:
	update_maps_local()


func _on_ZeroNetBrowse_pressed() -> void:
	update_maps_zn()

# double click
func _on_Maps_item_activated(index):
	print("item activated")
	emit_signal("double_clicked_map")
	get_tree().change_scene("res://scenes/default.tscn")

#single click
func _on_Maps_item_selected(index):
	globals.map = $VBoxContainer/BotPanel/MapBrowse/MarginContainer/Maps.get_item_text(index)
