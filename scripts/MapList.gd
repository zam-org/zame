extends ItemList

var MAP_DIR : = "res://maps/"
var maps : = []

signal double_clicked_map

func update_maps():
	clear()
	add_item("New Map")
	
	var dir = Directory.new()
	var err = dir.open(MAP_DIR)
	if err:
		print("Error encountered opening the maps directory. This should not have happened. Please stand up and dance circles around your chair till the problem is fixed.")
		return
		
	dir.list_dir_begin(true, false)
	var file_name = dir.get_next()
	while (file_name != ""):
		print(file_name)
		file_name = dir.get_next()
		if file_name.ends_with(".tscn") and file_name != "temp.tscn":
			add_item(file_name.trim_suffix(".tscn"))
#		print("Found map: " + file_name)
#			maps.append(file_name.trim_suffix(".tscn"))
#			add_item(maps[-1])
#		dir.get_next()
		
	dir.list_dir_end()
	print(maps)

func _on_MapList_item_selected(index):
	globals.map = get_item_text(index)
	print(globals.map)


func _on_MapList_item_activated(index):
	emit_signal("double_clicked_map")
