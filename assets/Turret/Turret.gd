extends StaticBody2D

onready var bullet : PackedScene = preload("res://assets/Turret/Bullet.tscn")

var type : String = "Turret"
var desired_direction : Vector2 setget set_direction, get_direction
var direction : Vector2 = Vector2.LEFT
var progress : = 2
var rotating : int = 0
var rotate_speed : float = 2.0

# for restarting the rotation
var original_rotation : float

# rate of fire
# 3 - slow
# 1 - medium
# 0.3 - fast

var rate_of_fire : float = 0.3 setget set_rof, get_rof
	
var speed : float = 1.0
	
	
func _ready():
	set_process(false)
	look_in_direction()
	
# call this function upon having it placed in the world
func boot() -> void:
	modulate.a = 1
	set_collision_layer_bit(0,true)
	set_collision_layer_bit(1,true)
	add_to_group("delete")	
	
func _process(delta):
	print(rotating)
	match rotating:
		0:
			speed = 0
		1:
			speed = 1 * rotate_speed
		2:
			speed = -1 * rotate_speed
			
	direction = direction.rotated(speed * delta)
	$Shape.rotation = direction.angle()
	
	
func shoot():
	var new_bullet = bullet.instance()
	new_bullet.position = new_bullet.position + (direction * 20)
	new_bullet.direction = direction
	add_child(new_bullet)
	new_bullet.shoot()

	
func activate():
	original_rotation = rotation
	set_process(true)
	$RateOfFire.wait_time = rate_of_fire
	$RateOfFire.start()

func deactivate():
	set_process(false)	
	$RateOfFire.stop()
	
func look_in_direction() -> void:
	$Shape.rotation = direction.angle()
	
	
# SETGETS	
func set_direction(new : Vector2) -> void:
	direction = new
	look_in_direction()
	
	
func get_direction():
	return direction
	
	
func set_rof(new):
	rate_of_fire = new
	
	
func get_rof():
	return rate_of_fire
	
func _on_RateOfFire_timeout():
	shoot()
	
	
# SAVING N LOADING
func save() -> Dictionary:
	var save_vars : Dictionary = {
		"name": self.name,
		"direction_x": direction.x,
		"direction_y": direction.y,
		"rotating": rotating,
		"rotate_speed": rotate_speed,
		"rate_of_fire": rate_of_fire,
		"speed": speed
		}
	
	return save_vars
	
	
func setup(vars : Dictionary) -> void:
	direction = Vector2(float(vars["direction_x"]), float(vars["direction_y"]))
	rotating = int(vars["rotating"])
	rotate_speed = float(vars["rotate_speed"])
	rate_of_fire = float(vars["rate_of_fire"])
	speed = float(vars["speed"])
	look_in_direction()
	
	print("Object with the name: ", self.name, " has been set up")
