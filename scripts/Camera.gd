extends Camera2D

var mouse_speed : Vector2
var smooth_mouse : Vector2

var smooth_pos : Vector2 = Vector2()

var pan_multiplier : int = 8

var play : bool = false

var shaking : bool = false
var shaking_multiplier : float = 1.0
var shake_amount : float = 0

var target_pos : Vector2 = Vector2()

func _process(delta):
	smooth_mouse = smooth_mouse.linear_interpolate(mouse_speed, 50 * delta)
	
	if Input.is_mouse_button_pressed(3):
		self.position -= smooth_mouse
	
	mouse_speed = Vector2()
	
	if shaking:
		self.offset = Vector2(rand_range(-shake_amount, shake_amount), rand_range(-shake_amount, shake_amount))
		
	if play:
		smooth_pos = smooth_pos.linear_interpolate(target_pos, 5 * delta)
		position = smooth_pos
		
func _input(event):
	if event is InputEventMouseMotion:
		mouse_speed = event.relative
	
	elif event is InputEventPanGesture:
		self.position += event.delta * pan_multiplier
		
#	shake it baby! set the strength and duration of the shake and watch the camera go wild
func shake(strength : float = 5.0, duration : float = 2.0):
	shaking = true
	shake_amount = strength
	$Tween.interpolate_property(self, 'shake_amount', shake_amount, 0, duration, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.start()
	yield($Tween, 'tween_completed')
	shaking = false

func activate():
	play = true

func deactivate():
	play = false

func _on_Finish_activated():
	shake(10.5, 2.2)

func _on_character_death():
	pass

func _on_character_pos(pos):
	target_pos = pos
