extends TextureButton

export(Color, RGBA) var mouse_over_colour : Color = Color(1.0,1.0,1.0,1.0)
export(float, 0, 1) var idle_transparency : float = 0.3

func _ready():
	modulate = Color(1,1,1,idle_transparency)
	self.connect("mouse_entered", self, "mouse_entered")
	self.connect("mouse_exited", self, "mouse_exited")

func mouse_entered():
	modulate = mouse_over_colour

func mouse_exited():
	modulate = Color(1,1,1,idle_transparency)