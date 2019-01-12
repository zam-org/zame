tool
extends Polygon2D

func _process(delta):
	position = get_global_mouse_position()
	
	if Engine.is_editor_hint():
		var mat = material
		mat.set_shader_param("location", position / 100)
	else:
		var mat = material
		mat.set_shader_param("location", position / 100)
		