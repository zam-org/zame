extends Node2D

onready var two : PackedScene = preload("res://assets/platforms/two/two.tscn") 

var toolkit : Array
var selected_tool

var grid_size = 20
var building_piece


func _ready():
	toolkit.append(two)
	selected_tool = 0
	reload()
#	var new_two = two.instance()
#	new_two.position = Vector2(0,0)
#	new_two.modulate.a = 0.5
#	add_child(new_two)
#	building_piece = new_two

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
			building_piece.set_collision_layer_bit(1,true)
			building_piece = null
			reload()
			
			
func reload() -> void:
	var new = toolkit[selected_tool].instance()
	new.modulate.a = 0.5
	new.remove_from_group("delete")
	add_child(new)
	building_piece = new
