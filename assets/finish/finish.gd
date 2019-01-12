extends StaticBody2D

export(Color, RGBA) var final_col : Color = Color(1,1,1,1)

var on : bool = false

signal activated

func _ready():
	pass # Replace with function body.

func fill_up() -> void:
	if on:
		return
	$Tween.interpolate_property($BackDoor, 'scale', $BackDoor.scale, Vector2(1,1), 5, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.start()
	yield($Tween, 'tween_completed')
	$Particles2.emitting = true
	$DoorShape.color = final_col
	emit_signal("activated")
	on = true