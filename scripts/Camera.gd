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

var BOTTOM_LIMIT : float

var character_velocity : Vector2

signal cam_pos(pos, mouse_pos)

func _process(delta):
#	if Input.is_action_pressed("zoom_in"):
#		zoom = Vector2(0.5,0.5)
#	elif Input.is_action_pressed("zoom_out"):
#		zoom = Vector2(1.5,1.5)
#	else:
#		zoom = Vector2(1,1)
	
	emit_signal("cam_pos", position, get_global_mouse_position())
	smooth_mouse = smooth_mouse.linear_interpolate(mouse_speed, 50 * delta)
	
	if Input.is_mouse_button_pressed(2) and !play:
		self.position -= smooth_mouse * zoom.x
	
	mouse_speed = Vector2()
	
	if shaking:
		self.offset = Vector2(rand_range(-shake_amount, shake_amount), rand_range(-shake_amount, shake_amount))
		
	if play:
		smooth_pos = smooth_pos.linear_interpolate(Vector2(target_pos.x, target_pos.y), 5 * delta)
		position.x = smooth_pos.x
		if smooth_pos.y + (OS.get_real_window_size().y / 2) < BOTTOM_LIMIT:
			position.y = smooth_pos.y
		
	$DigitalFog.material.set_shader_param("uv_offset", position / 2500)	
		
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
	yield(get_tree(), "idle_frame")
	if position.y + (OS.get_real_window_size().y / 2) > BOTTOM_LIMIT:
		position.y = BOTTOM_LIMIT - OS.get_real_window_size().y / 2

func deactivate():
	play = false

func _on_Finish_activated():
	shake(10.5, 2.2)

func _on_character_death():
	pass

func _on_character_pos(pos):
	target_pos = pos


func _on_MagnifyAmount_value_changed(value):
	zoom = Vector2(2 - value, 2 - value)


func _on_character_vel(vel):
	character_velocity = vel

func _on_Style_selected(style):
	match style:
		0:
			$DigitalFog.visible = false
			$Darkness.visible = false
			get_parent().grid_visible(true)
		1:
			$DigitalFog.visible = true
			$Darkness.visible = false
			get_parent().grid_visible(false)
		2:
			$DigitalFog.visible = false
			$Darkness.visible = true
			get_parent().grid_visible(true)
