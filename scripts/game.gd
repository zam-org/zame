extends Node2D

var grid_size = 20

var play : bool = false setget play_set, play_get
# waiting for a confirmation on these. Prevent players from messing things up.
var death_zone_confirm : bool = false

func _ready():
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
		play_set(!play)

# play a little audible click now
func play_click() -> void:
	$Audio/Click.play()
#
func _on_center_player6_pressed() -> void:
	play_click()
	$character.motion = Vector2()
	$character.position = $crosshair.position

func _on_character_death() -> void:
	death()
	
func death() -> void:
	$Audio/Damage.play()
	reset_character_pos()

func reset_character_pos() -> void:
	$Camera.shake(25.0, 1.5)
	$character.motion = Vector2()
	$character.position = $level/SpawnPos.global_position

# the button to change player spawn point moves the player spawn to the center of camera
func _on_Spawn_pressed() -> void:
	play_click()
	$level/SpawnPos.position = $crosshair.position

func _on_Finish_pressed() -> void:
	play_click()
	$Finish.position = $crosshair.position

func _on_pop_up_yes_pressed() -> void:
	play_click()
	if death_zone_confirm :
		$DeathZone.position.y = $crosshair.position.y

func _on_DeathArea_pressed():
	play_click()
	if $crosshair.position.y < $character.position.y:
		$editor_UI/ItemList/ConfirmPopUp.pop_up()
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

# Each node in the group play will have the functions activate and deactivate called when these buttons are pressed
func _on_Play_pressed():
	$Audio/Click.play()
	get_tree().call_group("play", "activate")

func _on_Stop_pressed():
	$Audio/Click.play()
	get_tree().call_group("play", "deactivate")


func activate():
	$crosshair.visible = false
	Input.set_mouse_mode(2)	
	
func deactivate():
	$character.position = $level/SpawnPos.global_position
	$crosshair.visible = true
	Input.set_mouse_mode(0)	