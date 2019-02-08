extends Control

var orig_position : Vector2
var slide_amount : float = 40

func _ready():
	orig_position = $Message.rect_position
	$Message.modulate = Color(1,1,1,0)

func notify(what : String = "WELL DONE") -> void:
	# stop the tweening first and hide the label
	$Tween.stop_all()
	$Message.modulate = Color(1,1,1,0)
		
	#set up the text and positions
	$Message.text = what
	var fade_in_pos = orig_position
	fade_in_pos.y = fade_in_pos.y - slide_amount
		
	var fade_out_pos = orig_position
	fade_out_pos.y = fade_out_pos.y + slide_amount
		
	#Animation in
	$Tween.interpolate_property($Message, 'rect_position', fade_in_pos, orig_position, 1, Tween.TRANS_ELASTIC, Tween.EASE_OUT, 0)
	$Tween.interpolate_property($Message, 'modulate', Color(1,1,1,0), Color(1,1,1,1), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	
	#Animation out
	$Tween.interpolate_property($Message, 'rect_position', orig_position, fade_out_pos, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 1.5)
	$Tween.interpolate_property($Message, 'modulate', Color(1,1,1,1), Color(1,1,1,0), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 1.5)
	
	$Tween.start()

func _on_game_show_notification(what : String):
	notify(what)


func _on_level_show_notification(what : String):
	notify(what.to_upper())
