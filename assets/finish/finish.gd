extends StaticBody2D

export(Color, RGBA) var final_col : Color = Color(1,1,1,1)
export(Color, RGBA) var orig_col : Color

var on : bool = false
var play : = false
signal activated

func _ready():
	orig_col = $DoorShape.color
	pass # Replace with function body.

func fill_up() -> void:
	if on or !play:
		return
	$Tween.interpolate_property($BackDoor, 'scale', $BackDoor.scale, Vector2(1,1), 5, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.start()
	yield($Tween, 'tween_completed')
	$Particles2.emitting = true
	$DoorShape.color = final_col
	emit_signal("activated")
	on = true
	$Sound.play()
	
func activate() -> void:
	play = true
	
func deactivate() -> void:
	$Tween.stop_all()
	$BackDoor.scale = Vector2(1,0.05)
	$Particles2.emitting = false
	on = false
	play = false
	$DoorShape.color = orig_col