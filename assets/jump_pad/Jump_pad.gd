extends StaticBody2D

#called upon being built
func boot() -> void:
	set_collision_layer_bit(2,true)
	$build_check.set_collision_layer_bit(10, true)
	$build_check.add_to_group("delete")
	modulate.a = 1
	add_to_group("delete")