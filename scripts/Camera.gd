extends Camera2D

var mouse_speed : Vector2
var smooth_mouse : Vector2

var pan_multiplier : int = 8

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	smooth_mouse = smooth_mouse.linear_interpolate(mouse_speed, 50 * delta)
	
	if Input.is_mouse_button_pressed(3):
		self.position -= smooth_mouse
	
	if Input.is_mouse_button_pressed(4):
		self.position.x += 1
	
	mouse_speed = Vector2()
		
func _input(event):
	print(event)
	if event is InputEventMouseMotion:
		mouse_speed = event.relative
	
	elif event is InputEventPanGesture:
		self.position += event.delta * pan_multiplier