extends KinematicBody2D

var desired_direction : Vector2 = Vector2(-1,0) setget desired_direction_set, desired_direction_get
var direction : Vector2 = Vector2()
var left : bool = true setget left_set, left_get
var dangerous : bool = false setget dangerous_set, dangerous_get
var dangerous_color : Color = Color(0.96875, 0.476215, 0.041626)
const SPEED = 30

var original_position : Vector2 = Vector2()
var original_direction : Vector2 = Vector2()

var original_rotation : int = 0
var current_rotation : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if dangerous:
		$Shape.color = dangerous_color
	set_physics_process(false)
	
func _physics_process(delta):
	move(delta)

func move(delta):
	var velocity = direction * SPEED * delta
	var collision = move_and_collide(velocity, true, true, false)
	if collision:
		change()
		
func change():
	position = position.snapped(Vector2(20,20))
	var rot : int
	if left:
		rot = -90
	else:
		rot = 90
	direction = direction.rotated(deg2rad(rot))

	current_rotation += rot
	$Tween.interpolate_property($Shape/Eye, 'rotation_degrees', $Shape/Eye.rotation_degrees, current_rotation, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.start()
	
func activate():
	direction = desired_direction
	set_physics_process(true)
	original_position = position
	original_direction = direction
	original_rotation = int(current_rotation)	
	
func deactivate():
	set_physics_process(false)
	position = original_position
	$Shape/Eye.look_at(to_global(original_direction * -1))
	current_rotation = original_rotation
	
# setters and getters	
func dangerous_set(yes):
	if yes:
		dangerous = true
		$Shape.color = dangerous_color
	else:
		dangerous = false
		$Shape.color = Color(1, 1, 1)
	
func dangerous_get():
	return dangerous	
	
func left_set(new : bool):
	left = new

func left_get():
	return left
	
func desired_direction_set(new : Vector2):
	print("setting direction")
	$Shape/Eye.look_at(to_global(new * -1))
	current_rotation = round($Shape/Eye.rotation_degrees)
	
	desired_direction = new
	
func desired_direction_get():
	return direction