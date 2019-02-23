extends KinematicBody2D

#	vectors!
var direction : Vector2
var motion : Vector2
var smooth_motion : Vector2

#	fun stuff with numbers for character controller
var speed : int = 12000
var gravity = 9.8 * 35

#	var used for sending the tilt amount to the player shape shader
var smooth_tilt : Vector2

var landed : bool = false
var in_air : bool = true
var jump_pad : bool = false
var play : bool = false
#	constants y'all!
const JUMP_POWER = 10000

#	did anyone say signals?
signal coin
signal death
signal pos(pos)
signal vel(vel)

func _process(delta):
	send_tilt_info(delta)
	if play:
		emit_signal("pos", position)
		emit_signal("vel", motion)	
	#	raycast to check for ground as "_is_on_floor()" was acting up
	if $floor_check.is_colliding():
		in_air = false
	else:
		$WalkParticles.emitting = false
		in_air = true
		landed = false

func _physics_process(delta):
	direction = Vector2()
	$WalkParticles.emitting = false

	if Input.is_action_pressed("left"):
		$WalkParticles.emitting = true
		direction.x -= 1
	if Input.is_action_pressed("right"):
		$WalkParticles.emitting = true
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
		play_jump_sound()
		motion.y -= JUMP_POWER * delta

	if jump_pad:
		motion.y = 0
		motion.y -= JUMP_POWER * 2 * delta
		jump_pad = false

	motion = move_and_slide(motion, Vector2(0,-1), false, 4, -0.1, true)

#	tilt direction changes depending on whether we're falling or gaining altitude
func send_tilt_info(delta) -> void:
	var mat = $shape.material

	if motion.y > 0.1:
		smooth_tilt = smooth_tilt.linear_interpolate(-motion, 3 * delta)
	else:
		smooth_tilt = smooth_tilt.linear_interpolate(motion, 10 * delta)
	
	randomize()
	
	if Input.is_action_pressed("left"):
		smooth_tilt.y = smooth_tilt.y + (smooth_tilt.x / 7)
	if Input.is_action_pressed("right"):
		smooth_tilt.y = smooth_tilt.y - (smooth_tilt.x / 7)

	mat.set_shader_param('disp', Vector2(-smooth_tilt.x / 20, (smooth_tilt.y * -1) / 10))
	
	var limit : float
	if in_air:
		limit = 0.1
	else:
		limit = 0.9
		
	mat.set_shader_param('limit', limit)


###	in order to be picked up the item needs to be on the third mask
func _on_check_body_entered(body) -> void:

	if body.is_in_group("coin") and play:
		body.queue_free()
		$audio/coin.play()
		emit_signal("coin")

	elif body.is_in_group("mine"):
		print("collided with danger")
		yield(get_tree(), 'idle_frame')
		death()

	elif body.is_in_group("jump_pad"):
		jump_pad = true
		$audio/JumpPad.play()
		body.anim()
		print("JUMP PAD")

	elif body.is_in_group("finish"):
		print("DA END")
		body.fill_up()

func _on_check_body_exited(body) -> void:
	if body.is_in_group("finish"):
		print("DA END NO MOAR")

func death() -> void:
	emit_signal("death")

func play_jump_sound() -> void:
	$audio/jump.play()
		
func activate():
	play = true
	
func deactivate():
	play = false
	
func enable_controls() -> void:
	set_physics_process(true)
	
func disable_controls() -> void:
	set_physics_process(false)