extends KinematicBody2D

var desired_direction : Vector2 = Vector2(-1,0) setget desired_direction_set, desired_direction_get
var direction : Vector2 = Vector2()

var soft : bool = false

const type : String = "Moving"

#	logic states
#	0 - turns left on impact
#	1 - turns right on impact
#	2 - turns around(bounces) on impact
var logic : int = true setget logic_set, logic_get
#var dangerous : bool = false setget dangerous_set, dangerous_get
#var dangerous_color : Color = Color(0.96875, 0.476215, 0.041626)
const SPEED = 30

var original_position : Vector2 = Vector2()
var original_direction : Vector2 = Vector2()

var original_rotation : int = 0
var current_rotation : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():

	set_physics_process(false)
	
func _physics_process(delta):
	move(delta)

func move(delta):
	var velocity = direction * SPEED * delta

	var collision = move_and_collide(velocity, true, true, false)
	if collision:
		if !soft and collision.collider.name == "character":
			return
		change()

		
func change():
	position = position.snapped(Vector2(20,20))
	var rot : int
	if logic == 0:
		rot = -90
	elif logic == 1:
		rot = 90
	else:
		rot = 180
	direction = direction.rotated(deg2rad(rot))

	current_rotation += rot
	print(current_rotation)
	$Tween.interpolate_property($Shape/Eye, 'rotation_degrees', $Shape/Eye.rotation_degrees, current_rotation - 180, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
#	$Tween.interpolate_property($Shape/Eye, 'rotation', $Shape/Eye.rotation, direction.angle_to(to_local(position)), 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)	
	$Tween.start()
	print(direction)
	
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
	
func logic_set(new : int):
	logic = new
	
func logic_get():
	return logic
	
func desired_direction_set(new : Vector2):
	print("setting direction")
	$Shape/Eye.look_at(to_global(new * -1))
	current_rotation = rad2deg(new.angle())
	print("Current rotation is: ", rad2deg(new.angle()))
	
	desired_direction = new
	
func desired_direction_get():
	return direction