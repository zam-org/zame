extends Node2D

func _on_CenterPlayer6_pressed() -> void:
	$character.motion = Vector2()
	$character.position = $Camera.position

func _on_character_death() -> void:
	reset_character_pos()
	
func reset_character_pos() -> void:
	$character.motion = Vector2()
	$character.position = $level/SpawnPos.global_position