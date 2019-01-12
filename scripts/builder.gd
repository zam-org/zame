extends Node2D

onready var two : PackedScene = preload("res://assets/platforms/two/two.tscn") 
onready var coin : PackedScene = preload("res://assets/coin/coin.tscn") 
onready var jump_pad : PackedScene = preload("res://assets/jump_pad/jump_pad.tscn") 
onready var mine : PackedScene = preload("res://assets/mine/mine.tscn") 

var toolkit : Array
var selected_tool : int

var grid_size = 20
var building_piece

var can_build : bool = true
var building : bool = false

func _ready():
	toolkit.clear()
	toolkit.append(two)
	toolkit.append(coin)
	toolkit.append(jump_pad)
	toolkit.append(mine)	
	selected_tool = 0
	reload()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and can_build == true:
			building = true
		elif event.button_index == 1 and !event.pressed:
			building = false
		#switch tools
		if event.button_index == 4 and event.pressed:
			if selected_tool > 0:
				selected_tool -= 1
				reload(true)
		elif event.button_index == 5 and event.pressed:
			if selected_tool < toolkit.size() - 1 :
				selected_tool += 1
				reload(true)

func _process(delta):
	var grid_pos = get_local_mouse_position()
	grid_pos.x = round(grid_pos.x/grid_size) * grid_size
	grid_pos.y = round(grid_pos.y/grid_size) * grid_size
	
#	$delete.position = grid_pos
	$delete.position = get_local_mouse_position()	
	
	
	if Input.is_mouse_button_pressed(2):
		var overlapping = $delete.get_overlapping_bodies()
		if overlapping.size() > 0:
			for i in overlapping:
				if i.is_in_group("delete"):
					i.queue_free()
	
	if can_build:
		building_piece.position = grid_pos
	
	if building:
		build_current_piece()
		building = false
	
func build_current_piece():
	if $delete.get_overlapping_bodies().size() > 0:
		return
	building_piece.modulate.a = 1
	building_piece.add_to_group("delete")
	
	#	set up collision based on what the item is
	#	1 - static
	#	2 - pickup/interactive, eg. coins and jumppads
	#	3 - traps
	
	if building_piece.is_in_group('small'):
		building_piece.set_collision_layer_bit(2,true)
		building_piece.get_node("build_check").set_collision_layer_bit(10, true)
	else:
		building_piece.set_collision_layer_bit(0,true)
		building_piece.set_collision_layer_bit(1,true)		
		building_piece = null
	can_build = false
	reload()
	$BlockPlaced.play()
	print(get_children())
	
func reload(clean : bool = false) -> void:
	if clean:
		can_build = false
		building_piece.queue_free()
		building_piece = null
	var new = toolkit[selected_tool].instance()
	new.visible = false
	new.modulate.a = 0.5
	add_child(new)
	building_piece = new
	can_build = true
	yield(get_tree(), 'idle_frame')
	building_piece.visible = true

###	UI SELECTION OF TOOLS SINGALS
func _on_Block_pressed():
	selected_tool = 0
	reload(true)
	
func _on_coin_pressed():
	selected_tool = 1
	reload(true)

func _on_JumpPad_pressed():
	selected_tool = 2
	reload(true)

func _on_Mine_pressed():
	selected_tool = 3
	reload(true)

func _on_Reset_pressed():
	get_tree().reload_current_scene()

