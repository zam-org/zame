extends Node2D

var grid_size = 20

var play : bool = false setget play_set, play_get
# waiting for a confirmation on these. Prevent players from messing things up.
var death_zone_confirm : bool = false
var exit_confirm : bool = false
var save_confirm : bool = false

signal show_notification(what)

func _ready():
	VisualServer.viewport_set_msaa(get_viewport().get_viewport_rid(), globals.MSAA)
	get_viewport().set_msaa(globals.MSAA)
	$crosshair.position = Vector2()
	
	if globals.map != "":
		load_map(globals.map)
		yield(get_tree(), "idle_frame")
		$level.set_process(true)
		$level.reload()
	else:
		$level.set_process(true)
		$level.reload()


# Runs every frame
func _process(delta):
	$bloom.rect_position = $Camera.position + Vector2(-640, -360)

	# position crosshair
	var grid_pos = $Camera.position
	grid_pos.x = round(grid_pos.x/grid_size) * grid_size
	grid_pos.y = round(grid_pos.y/grid_size) * grid_size

	$crosshair.position = grid_pos

	# check for the death zone and move the label to the middle of the camera
	if $character.position.y > $DeathZone.position.y:
		death()

	$DeathZone/Label.rect_position.x = $Camera.position.x + 450
	
	if Input.is_action_just_pressed("ui_select"):
		$Audio/Click.play()
		play_set(!play)
	if Input.is_action_just_pressed("ui_cancel"):
		$Audio/Click.play()
		exit_confirm_popup()
	
	if Input.is_action_just_pressed("8") and !play:
		move_spawn()
	elif Input.is_action_just_pressed("9") and !play:
		move_death_area()
	elif Input.is_action_just_pressed("0") and !play:
		move_finish()
	elif Input.is_action_just_pressed("reset") and !play:
		$character.motion = Vector2()
		$character.position = $level/SpawnPos.global_position

func _input(event):
	if event is InputEventKey:
		if event.as_text() == "Kp Add" and event.pressed:
			$editor_UI/ZoomContainer/MagnifyingGlassPlus.emit_signal("pressed")
		elif event.as_text() == "Kp Subtract" and event.pressed:
			$editor_UI/ZoomContainer/MagnifyingGlassMinus.emit_signal("pressed")

func check_when_moving() -> bool:
	var can : bool
	$crosshair/RayCast.enabled = true
	can = false if $crosshair/RayCast.is_colliding() else true
	return can

# play a little audible click. NOW!
func play_click() -> void:
	$Audio/Click.play()

# le Signals
func _on_CenterPlayer6_pressed() -> void:
	center_player()

func _on_character_death() -> void:
	death()
	
func death() -> void:
	$Audio/Damage.play()
	reset_character_pos()

func _on_Spawn_pressed() -> void:
	move_spawn()
	
func _on_Finish_pressed() -> void:
	move_finish()
	
func _on_DeathArea_pressed():
	move_death_area()
	
func _on_Exit_pressed() -> void:
	exit_confirm_popup()

func _on_Play_pressed():
	$Audio/Click.play()
	get_tree().call_group("play", "activate")

#	POP UP SIGNALS
func _on_pop_up_yes_pressed() -> void:
	$character.enable_controls()	
	play_click()
	if death_zone_confirm:
		death_zone_confirm = false
		$DeathZone.position.y = $crosshair.position.y
		emit_signal("show_notification", "DEATH ZONE MOVED DANGEROUSLY")

	elif exit_confirm:
		exit_confirm = false
		get_tree().change_scene("res://scenes/main_menu.tscn")
		
	elif save_confirm:
		save_confirm = false
		save_map($editor_UI/ConfirmPopUp.get_input())
		

func _on_No_pressed():
	$character.enable_controls()	
	$Audio/Click.play()
	death_zone_confirm = false
	exit_confirm = false
	save_confirm = false

# Moving functions	
func reset_character_pos() -> void:
	$Camera.shake(25.0, 1.5)
	$character.motion = Vector2()
	$character.position = $level/SpawnPos.global_position
	emit_signal("show_notification", "PLAYER RESPAWNED")

func center_player() -> void:
	play_click()
	$character.motion = Vector2()
	$character.position = $crosshair.position
	emit_signal("show_notification", "PLAYER CENTERED")	

func move_spawn() -> void:
	play_click()
	var can_move = check_when_moving()
	yield(get_tree(), 'idle_frame')
	if can_move:
		$level/SpawnPos.position = $crosshair.position
		emit_signal("show_notification", "MOVED PLAYER SPAWN")	
	else:
		emit_signal("show_notification", "ERROR: CANNOT MOVE PLAYER SPAWN THERE. TOO MUCH STUFF TOO LITTLE SPACE")

func move_finish():
	var can_move = check_when_moving()
	if can_move:
		$Finish.position = $crosshair.position
		emit_signal("show_notification", "MOVED FINISH")
	else:
		emit_signal("show_notification", "ERROR: CANNOT MOVE FINISH THERE. TOO MUCH STUFF TOO LITTLE SPACE")
		
func move_death_area() -> void:
	play_click()
	if $crosshair.position.y < $character.position.y:
		$editor_UI/ConfirmPopUp.pop_up("Placing the Death Zone above the player will cause an endless respawn. A headache is likely to follow. \n\n Are you sure buds? Justsayin")
		$character.disable_controls()
		death_zone_confirm = true
		return
	$DeathZone.position.y = $crosshair.position.y

# setget
func play_set(new):
	play = new
	if new:
		# save the current level node
		save_map()
		yield(get_tree(), 'idle_frame')
		get_tree().call_group_flags(1, "play", "activate")
		
		#hide the crosshair
		$crosshair.visible = false
		#move the character to starting position
		$character.position = $level/SpawnPos.global_position
		emit_signal("show_notification", "GAME ON!")
	else:
		# load the temporarily saved level
		load_map()

		# Call deactivate function for nodes and move character back into position.
		get_tree().call_group_flags(1, "play", "deactivate")
		$crosshair.visible = true
	
func save_map(map_name : String = "temp") -> void:
	var map_vars : Dictionary = {
		"finish_x" : $Finish.position.x,
		"finish_y" : $Finish.position.y,
		"death_zone_y" : $DeathZone.position.y,
		"player_spawn_y" : $level/SpawnPos.position.y,
		"player_spawn_x" : $level/SpawnPos.position.x
		}
	
	var content = $level/Content
	
	# First we save the node options, should there be any to be saved
	var map_settings : File = File.new()
	map_settings.open(globals.level_path + map_name + ".settings", File.WRITE)
	
	for i in content.get_children():
		if i.has_method("save"):
			var vars = i.save()
			map_settings.store_line(to_json(vars))
	
	map_settings.store_line(to_json(map_vars))
	map_settings.close()
	
	# Finally we pack the scene and save it as a temp file
	var packed_scene = PackedScene.new()
	var err = packed_scene.pack(content)
	print(err)
	ResourceSaver.save(globals.level_path + map_name + ".tscn", packed_scene)
	
	emit_signal("show_notification", "MAP SAVED")
		
func load_map(map_name : String = "temp") -> void:
	var packed_scene = load(globals.level_path + map_name + ".tscn")
	
	#break the process should we not be able to load a map
	if packed_scene == null:
		return
	# delete current level and wait a frame for it to get deleted	
	$level/Content.queue_free()
	yield(get_tree(), 'idle_frame')
	# Instance the scene
	var my_scene = packed_scene.instance()
	$level.add_child(my_scene)
	my_scene.name = "Content"
	
	#set the new content folder
	$level.content = my_scene
	
	# load the settings of the objects within the scene
	var map_settings = File.new()
	map_settings.open(globals.level_path + map_name + ".settings", File.READ)
	while not map_settings.eof_reached():
		var current_line = parse_json(map_settings.get_line())
		if current_line is Dictionary and !current_line.has("death_zone_y"):
			var path : String = "level/Content/" + current_line["name"]
			var object = get_node(path)
			if object != null:
				object.setup(current_line)
				
		elif current_line is Dictionary and current_line.has("death_zone_y"):
			$Finish.position.x = float(current_line["finish_x"])
			$Finish.position.y = float(current_line["finish_y"])
			$DeathZone.position.y = float(current_line["death_zone_y"])
			$level/SpawnPos.position.x = float(current_line["player_spawn_x"])
			$level/SpawnPos.position.y = float(current_line["player_spawn_y"])
			$character.position = $level/SpawnPos.position
		
	map_settings.close()
	
	# last step of loading is calling the boot function in every object,
	# this gives them correct collision masks
	# and adds to correct groups.
	# Each buildable object has this function
	
	for i in $level/Content.get_children():
#		print(i.name)
		i.boot()
	
	emit_signal("show_notification", "MAP LOADED")
	
func play_get():
	return play
	

# Each node in the group play must have the functions activate and deactivate called when these buttons are pressed
func activate():
	$crosshair.visible = false
	$DeathZone.visible = false
	$Camera.BOTTOM_LIMIT = $DeathZone.position.y
	Input.set_mouse_mode(2)
	
	
func deactivate():
	$character.position = $level/SpawnPos.global_position
	$crosshair.visible = true
	$DeathZone.visible = true
	Input.set_mouse_mode(0)
	
	
func exit_confirm_popup() -> void:
	exit_confirm = true
	$editor_UI/ConfirmPopUp.pop_up("Quit to main menu? \n (All unsaved progress will be lost)")
	$character.disable_controls()	
	

func _on_Save_pressed():
	save_confirm = true
	$editor_UI/ConfirmPopUp.pop_up("Save map to disk", "", "", true)
	$character.disable_controls()	
	
	


func _on_Yes_Publish_To_ZeroNet_pressed():
	var version : String = ProjectSettings.get("application/config/version")
	var map_name : String = $editor_UI/PublishLevelPopUp/Window/Horizontal/TextContainer/MapName.text
	var description : String = $editor_UI/PublishLevelPopUp/Window/Horizontal/TextContainer/Description.text
	
	print(version, map_name, description)
	# Send the map to zeronet below
	# Check save_map function above for inspiration
	
	emit_signal("show_notification", "PUBLISHED TO ZERONET")