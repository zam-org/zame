extends KinematicBody2D

var direction : Vector2
var motion : Vector2
var smooth_motion : Vector2
var speed : int = 12000
var gravity = 9.8 * 20

const JUMP_POWER = 10000

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
	
	if Input.is_action_pressed("up") && is_on_floor():
		motion.y -= JUMP_POWER * delta
	
	motion = move_and_slide(motion, Vector2(0,-1))
	
func _on_check_body_entered(body):
	body.queue_free()
	$audio/coin.play()
