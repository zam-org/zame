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

var mouse_grid_pos : Vector2

# STATS

# start off with a single built object as we have that as a ledge for the player to stand on
var built_objects : int = 1
var removed_objects : int = 0

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
#		if the LMB has been clicked the building mode is set on to toggle PAINT building in _process
		if event.button_index == 1 and event.pressed:
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
	if $delete.get_overlapping_bodies().size() > 0:
		can_build = false
	else:
		can_build = true
		
	mouse_grid_pos = get_grid_pos(get_local_mouse_position())
	
	$delete.position = mouse_grid_pos


	if Input.is_mouse_button_pressed(2):
		var overlapping = $delete.get_overlapping_bodies()
		if overlapping.size() > 0:
			for i in overlapping:
				if i.is_in_group("delete"):
					i.queue_free()
					$Audio/BlockDeleted.play()
					built_objects -= 1
					removed_objects += 1

	if can_build:
		building_piece.position = mouse_grid_pos

	if building:
		build_current_piece()

func get_grid_pos(pos : Vector2) -> Vector2:
	var new_grid_pos = pos
	new_grid_pos.x = round(new_grid_pos.x/grid_size) * grid_size
	new_grid_pos.y = round(new_grid_pos.y/grid_size) * grid_size
	
	return new_grid_pos

func build_current_piece() -> void:
	if !can_build:
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
		
	reload()
	$Audio/BlockPlaced.play()
	built_objects += 1

# called to put a new item under the mouse's grid posiiton aka. the item to be built
func reload(clean : bool = false) -> void:
	# the clean call is when the previous piece wasn't removed before hand
	# this happens when selecting new tools
	if clean:
		building_piece.queue_free()
		
	building_piece = null
	var new = toolkit[selected_tool].instance()
	new.position = mouse_grid_pos

#	activate collision if we've just loaded a 2x2 block
#	--- edit this one out should you not want for the building block to collide with character
#	--- except don't because it's totally awesome
	if selected_tool == 0:
		new.set_collision_layer_bit(0,true)

	new.visible = false
	new.modulate.a = 0.5
	add_child(new)
	building_piece = new
	yield(get_tree(), 'idle_frame')
	building_piece.visible = true

func play_click() -> void:
	$Audio/Click.play()

###	UI SELECTION OF TOOLS SINGALS
func _on_Block_pressed() -> void:
	play_click()
	selected_tool = 0
	reload(true)

func _on_coin_pressed() -> void:
	play_click()
	selected_tool = 1
	reload(true)

func _on_JumpPad_pressed() -> void:
	play_click()
	selected_tool = 2
	reload(true)

func _on_Mine_pressed() -> void:
	play_click()
	selected_tool = 3
	reload(true)

func _on_Reset_pressed() -> void:
	play_click()
	get_tree().reload_current_scene()

