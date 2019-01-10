extends KinematicBody2D

#	vectors!
var direction : Vector2
var motion : Vector2
var smooth_motion : Vector2

#	fun stuff with numbers for character controller
var speed : int = 12000
var gravity = 9.8 * 20

#	var used for sending the tilt amount to the player shape shader
var smooth_tilt : Vector2

var landed : bool = false
var in_air : bool = true
var jump_pad : bool = false
#	constants y'all!
const JUMP_POWER = 10000

#	did anyone say signals?
signal coin

func _process(delta):
	var mat = $shape.material
	
#	tilt direction changes depending on whether we're falling or gaining altitude
	if motion.y > 0.1:
		smooth_tilt = smooth_tilt.linear_interpolate(-motion, 3 * delta)
	else:
		smooth_tilt = smooth_tilt.linear_interpolate(motion, 10 * delta)
		
	mat.set_shader_param('disp', smooth_tilt / 10)
	
	#	raycast to check for ground as "_is_on_floor()" was acting up
	if $floor_check.is_colliding():
		in_air = false
	else:
		in_air = true
		landed = false

func _physics_process(delta):
	direction = Vector2()
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
		
	direction = direction.normalized()
	
#	seperate slerp because gravity
	smooth_motion = smooth_motion.linear_interpolate(direction * speed * delta, 5 * delta) 
	
	motion.x = smooth_motion.x
	
	#	gravity is faster when falling
	if !is_on_floor():
		if motion.y > 0:
			motion.y += gravity * 2* delta
		else:
			motion.y += gravity * delta			
	else:
		if !landed:
			$animations.play("landing")
			landed = true
	
	if Input.is_action_pressed("up") && is_on_floor():
		$animations.play("jump")
		motion.y -= JUMP_POWER * delta
	
	if jump_pad:
		motion.y -= JUMP_POWER * 2 * delta
		jump_pad = false
	
	motion = move_and_slide(motion, Vector2(0,-1), false, 4, -0.1, true)
	
func _on_check_body_entered(body):
	if body.is_in_group("coin"):
		body.queue_free()
		$audio/coin.play()
		emit_signal("coin")
	elif body.is_in_group("jump_pad"):
		jump_pad = true
		print("JUMP PAD")
