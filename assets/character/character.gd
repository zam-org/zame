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

#	constants y'all!
const JUMP_POWER = 10000

#	did anyone say signals?
signal coin

func _process(delta):
	var mat = $shape.material
	smooth_tilt = smooth_tilt.linear_interpolate(motion, 10 *delta)
	smooth_tilt.x = smooth_tilt.x / 1.5
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
	
	smooth_motion = smooth_motion.linear_interpolate(direction * speed * delta, 5 * delta) 
	motion.x = smooth_motion.x
	
	#	gravity is faster when falling
	if !is_on_floor():
		if motion.y > 0:
			motion.y += gravity * 2* delta
		else:
			motion.y += gravity * delta			
	else:
		motion.y += 1
		if !landed:
			$animations.play("landing")
			landed = true
	
	if Input.is_action_pressed("up") && is_on_floor():
		$animations.play("jump")
		motion.y -= JUMP_POWER * delta
	
	motion = move_and_slide(motion, Vector2(0,-1), false, 4, -0.1, true)
	
func _on_check_body_entered(body):
	body.queue_free()
	$audio/coin.play()
	emit_signal("coin")
