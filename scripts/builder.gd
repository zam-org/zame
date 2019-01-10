extends Node2D

onready var two : PackedScene = preload("res://assets/platforms/two/two.tscn") 
onready var coin : PackedScene = preload("res://assets/coin/coin.tscn") 

var toolkit : Array
var selected_tool

var grid_size = 20
var building_piece


func _ready():
	toolkit.append(two)
	toolkit.append(coin)	
	selected_tool = 0
	reload()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 4:
			selected_tool = 0
			reload(true)
		elif event.button_index == 5:
			selected_tool = 1
			reload(true)

func _process(delta):
	var grid_pos = get_local_mouse_position()
	grid_pos.x = round(grid_pos.x/grid_size) * grid_size
	grid_pos.y = round(grid_pos.y/grid_size) * grid_size
	
	$delete.position = get_local_mouse_position()
	
	if Input.is_mouse_button_pressed(2):
		var overlapping = $delete.get_overlapping_bodies()
		if overlapping.size() > 0:
			for i in overlapping:
				if i.is_in_group("delete"):
					i.queue_free()
	
	if building_piece != null:
		building_piece.position = grid_pos
	
		if Input.is_mouse_button_pressed(1) and $delete.get_overlapping_bodies().size() == 0:
			building_piece.modulate.a = 1
			building_piece.add_to_group("delete")
			
			#	set up collision based on what the item is
			#	1 - static
			#	2 - pickup, eg. coins
			#	3 - traps
			
			if building_piece.is_in_group('coins'):
				building_piece.set_collision_layer_bit(2,true)
				building_piece.get_node("build_check").set_collision_layer_bit(10, true)
			else:
				building_piece.set_collision_layer_bit(1,true)
			building_piece = null
			reload()
			
			
func reload(clean : bool = false) -> void:
	if clean:
		building_piece.queue_free()
		building_piece = null
	var new = toolkit[selected_tool].instance()
	new.modulate.a = 0.5
	add_child(new)
	building_piece = new
	print(building_piece.name)
