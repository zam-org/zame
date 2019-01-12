extends Polygon2D

func _process(delta):
	position = get_global_mouse_position()
	
	var mat = material
	mat.set_shader_param("location", position / 300)