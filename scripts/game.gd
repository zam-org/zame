extends Node2D

var grid_size = 20

var play : bool = false setget play_set, play_get
# waiting for a confirmation on these. Prevent players from messing things up.
var death_zone_confirm : bool = false
var exit_confirm : bool = false

func _ready():
	VisualServer.viewport_set_msaa(get_viewport().get_viewport_rid(), globals.MSAA)
	$crosshair.position = Vector2()


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
	if Input.is_action_just_pressed("ui_cancel") and !play:
		$Audio/Click.play()
		exit_confirm_popup()		
	if Input.is_action_just_pressed("ui_cancel") and play:
		$Audio/Click.play()
		play_set(false)
	
	if Input.is_action_just_pressed("8") and !play:
		move_spawn()
	elif Input.is_action_just_pressed("9") and !play:
		move_death_area()
	elif Input.is_action_just_pressed("0") and !play:
		move_finish()
	elif Input.is_action_just_pressed("reset") and !play:
		$character.motion = Vector2()
		$character.position = $level/SpawnPos.global_position

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
	play_click()
	if death_zone_confirm:
		death_zone_confirm = false		
		$DeathZone.position.y = $crosshair.position.y

	if exit_confirm:
		exit_confirm = false
		get_tree().change_scene("res://scenes/main_menu.tscn")

func _on_No_pressed():
	$Audio/Click.play()
	death_zone_confirm = false
	exit_confirm = false

# Moving functions	
func reset_character_pos() -> void:
	$Camera.shake(25.0, 1.5)
	$character.motion = Vector2()
	$character.position = $level/SpawnPos.global_position

func center_player() -> void:
	play_click()
	$character.motion = Vector2()
	$character.position = $crosshair.position	

func move_spawn() -> void:
	play_click()
	$level/SpawnPos.position = $crosshair.position

func move_finish():
	play_click()
	$Finish.position = $crosshair.position
	
func move_death_area() -> void:
	play_click()
	if $crosshair.position.y < $character.position.y:
		$editor_UI/ConfirmPopUp.pop_up("Placing the Death Zone above the player will cause an endless respawn. A headache is likely to follow. \n\n Are you sure buds? Justsayin")
		death_zone_confirm = true
		return
	$DeathZone.position.y = $crosshair.position.y

# setget
func play_set(new):
	play = new
	if new:
		get_tree().call_group_flags(1, "play", "activate")
		$crosshair.visible = false
	else:
		get_tree().call_group_flags(1, "play", "deactivate")
		$character.position = $level/SpawnPos.global_position
		$crosshair.visible = true	
	
func play_get():
	return play

# Each node in the group play must have the functions activate and deactivate called when these buttons are pressed
func activate():
	$crosshair.visible = false
	Input.set_mouse_mode(2)	
	
func deactivate():
	$character.position = $level/SpawnPos.global_position
	$crosshair.visible = true
	Input.set_mouse_mode(0)	
	
func exit_confirm_popup() -> void:
	exit_confirm = true
	$editor_UI/ConfirmPopUp.pop_up("Quit to main menu? \n (All unsaved progress will be lost)")

