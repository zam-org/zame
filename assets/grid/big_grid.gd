extends Polygon2D

var play : bool = false
var target_pos : Vector2 = Vector2()

func _process(delta):
	if !play:
		position = get_global_mouse_position()
	else:
		position = target_pos

	var mat = material
	mat.set_shader_param("location", position / 300)
	
func activate():
	play = true
	
func deactivate():
	play = false

func _on_character_pos(pos):
	target_pos = pos