extends Camera2D

var mouse_speed : Vector2
var smooth_mouse : Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	smooth_mouse = smooth_mouse.linear_interpolate(mouse_speed, 50 * delta)
	
	if Input.is_mouse_button_pressed(3):
		self.position -= smooth_mouse
	
	mouse_speed = Vector2()
		
func _input(event):
	if event is InputEventMouseMotion:
		mouse_speed = event.relative
