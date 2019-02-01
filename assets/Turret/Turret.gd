extends StaticBody2D

onready var bullet : PackedScene = preload("res://assets/Turret/Bullet.tscn")

var type : String = "Turret"
var desired_direction : Vector2 setget set_direction, get_direction
var direction : Vector2 = Vector2.LEFT
var progress : = 2
var rotating : int = 0
var rotate_speed : float = 2.0

# rate of fire
# 3 - slow
# 1 - medium
# 0.3 - fast

var rate_of_fire : float = 0.3 setget set_rof, get_rof
	
var speed = 1
	
	
func _ready():
	set_process(false)
	look_in_direction()
	
	
func _process(delta):
	match rotating:
		0:
			return
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
