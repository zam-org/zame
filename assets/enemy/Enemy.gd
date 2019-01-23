extends KinematicBody2D

var direction : Vector2 = Vector2(-1,0)
var left : bool = true setget left_set, left_get
var dangerous : bool = false setget dangerous_set, dangerous_get
var dangerous_color : Color = Color(0.96875, 0.476215, 0.041626)
const SPEED = 30

var original_position : Vector2 = Vector2()

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
	set_physics_process(true)
	original_position = position
	
func deactivate():
	set_physics_process(false)
	position = original_position

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
	
func left_set(new):
	if new:
		left = true
		$Shape/Eye.rotation_degrees = 0
		current_rotation = 0
		direction.x = -1
	else:
		left = false
		$Shape/Eye.rotation_degrees = 180
		current_rotation = 180
		direction.x = 1

func left_get():
	return left
	