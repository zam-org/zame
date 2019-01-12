extends Node2D

var grid_size = 20

#	waiting for a confirmation on these. Prevent players from fucking up.
var death_zone_confirm : bool = false

func _ready():
	$crosshair.position = Vector2()

func _process(delta):
	$bloom.rect_position = $Camera.position + Vector2(-640, -360)
	#position crosshair
	var grid_pos = $Camera.position
	grid_pos.x = round(grid_pos.x/grid_size) * grid_size
	grid_pos.y = round(grid_pos.y/grid_size) * grid_size
	
	$crosshair.position = grid_pos

	## check for the death zone && move the label to the middle of the camera
	if $character.position.y > $DeathZone.position.y:
		reset_character_pos()
		
	$DeathZone/Label.rect_position.x = $Camera.position.x + 450

func _on_CenterPlayer6_pressed() -> void:
	$character.motion = Vector2()
	$character.position = $Camera.position

func _on_character_death() -> void:
	reset_character_pos()
	
func reset_character_pos() -> void:
	$character.motion = Vector2()
	$character.position = $level/SpawnPos.global_position

#	the button to change player spawn point moves the player spawn to the center of camera
func _on_Spawn_pressed() -> void:
	$level/SpawnPos.position = $crosshair.position

func _on_Finish_pressed() -> void:
	$Finish.position = $crosshair.position

func _on_DeathArea_pressed() -> void:
	if $crosshair.position.y < $character.position.y:
		$UI/ItemList/ConfirmPopUp.pop_up()
		death_zone_confirm = true
		return
	$DeathZone.position.y = $crosshair.position.y


func _on_pop_up_yes_pressed() -> void:
	if death_zone_confirm :
		$DeathZone.position.y = $crosshair.position.y
