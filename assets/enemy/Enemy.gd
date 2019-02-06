extends KinematicBody2D

var desired_direction : Vector2 = Vector2(-1,0) setget desired_direction_set, desired_direction_get
var direction : Vector2 = Vector2()

var original_color : Color = Color("eb9111")
var hit_color : Color = Color(1, 0.890625, 0)

const type : String = "Enemy"

#	logic states
#	0 - turns left on impact
#	1 - turns right on impact
#	2 - turns around(bounces) on impact
var logic : int = true setget logic_set, logic_get
#var dangerous : bool = false setget dangerous_set, dangerous_get
#var dangerous_color : Color = Color(0.96875, 0.476215, 0.041626)
const SPEED = 30

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
		if collision.collider.name == "character":
			collision.collider.death()
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
	$Tween.interpolate_property($Shape/Eye, 'rotation_degrees', $Shape/Eye.rotation_degrees, current_rotation - 180, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.interpolate_property($Shape, 'color', hit_color, original_color, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)	
	$Tween.start()
	
# call this function upon having it placed in the world
func boot() -> void:
	modulate.a = 1
	set_collision_layer_bit(0,true)
	set_collision_layer_bit(1,true)
	set_collision_mask_bit(0,true)
	add_to_group("delete")
	
func activate():
	direction = desired_direction
	set_physics_process(true)
	
func deactivate():
	set_physics_process(false)
	pass
	
func logic_set(new : int):
	logic = new
	
	
func logic_get():
	return logic
	
	
func desired_direction_set(new : Vector2):
	$Shape/Eye.look_at(to_global(new * -1))
	current_rotation = rad2deg(new.angle())	
	desired_direction = new
	direction = new
	
func desired_direction_get():
	return direction
	
	
# SAVING N LOADING
func save() -> Dictionary:
	var save_vars : Dictionary = {
		"name": self.name,
		"direction_x": direction.x,
		"direction_y": direction.y,
		"logic": logic
		}
	
	return save_vars
	
	
func setup(vars : Dictionary) -> void:
	desired_direction_set(Vector2(float(vars["direction_x"]), float(vars["direction_y"])))
	boot()
	logic = int(vars["logic"])

	print("Object with the name: ", self.name, " has been set up")