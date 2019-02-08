extends Control

var orig_position : Vector2
var animation_offset : float = 40.0

var achievement_length : float = 2.0

func _ready():
	modulate = Color(1,1,1,0)
	$UnlockedLabel.modulate = Color(1,1,1,0)
	orig_position = rect_position

func achievement_show(image_path : String = "", achievement_name : String = "", achievement_info : String = "", length : float = 2.0) -> void:
	$UnlockedLabel.modulate = Color(1,1,1,0)	
	$Tween.stop_all()
	achievement_length = length
	
	# set text
	$HBoxContainer/VBoxContainer/AchievementInfo.text = achievement_info
	$HBoxContainer/VBoxContainer/AchievementName.text = achievement_name
	
	
	# animation position
	var fade_in_pos = Vector2(orig_position.x, orig_position.y - animation_offset)
	var fade_out_pos = Vector2(orig_position.x, orig_position.y + animation_offset)
	
	# fade in
	$Tween.interpolate_property(self, 'rect_position', fade_in_pos, orig_position, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.interpolate_property(self, 'modulate', Color(1,1,1,0), Color(1,1,1,1), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.interpolate_property($UnlockedLabel, 'modulate', Color(1,1,1,0), Color(1,1,1,1), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.15)
	
	# fade out
	$Tween.interpolate_property(self, 'rect_position', orig_position, fade_in_pos, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, achievement_length)
	$Tween.interpolate_property(self, 'modulate', Color(1,1,1,1), Color(1,1,1,0), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, achievement_length)
	$Tween.interpolate_property($UnlockedLabel, 'modulate', Color(1,1,1,1), Color(1,1,1,0), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, achievement_length / 2)
	
	# start the tween
	$Tween.start()
	
# testing the achievements
func _process(delta):
	if Input.is_action_just_pressed("achievement"):
		achievement_show("", "BUILDER - lvl 5", "Built over 5000 pieces", 4.0)
		
	elif Input.is_action_just_pressed("achievement_2"):
		achievement_show("", "DESTROYER - lvl 1", "Removed over 500 pieces", 4.0)