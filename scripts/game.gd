extends Node2D

var grid_size = 20

func _ready():
	$crosshair.position = Vector2()

func _process(delta):
	$bloom.rect_position = $Camera.position + Vector2(-640, -360)
	#position crosshair
	var grid_pos = $Camera.position
	grid_pos.x = round(grid_pos.x/grid_size) * grid_size
	grid_pos.y = round(grid_pos.y/grid_size) * grid_size
	
	$crosshair.position = grid_pos

func _on_CenterPlayer6_pressed() -> void:
	$character.motion = Vector2()
	$character.position = $Camera.position

func _on_character_death() -> void:
	reset_character_pos()
	
func reset_character_pos() -> void:
	$character.motion = Vector2()
	$character.position = $level/SpawnPos.global_position

#	the button to change player spawn point moves the player spawn to the center of camera
func _on_Spawn_pressed():
	$level/SpawnPos.position = $crosshair.position