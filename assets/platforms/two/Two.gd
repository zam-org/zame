extends StaticBody2D

#called upon being built
func boot() -> void:
	set_collision_layer_bit(0,true)
	set_collision_layer_bit(1,true)
	modulate.a = 1
	add_to_group("delete")