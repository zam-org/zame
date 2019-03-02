extends Control

onready var parent = get_parent()
var dip_amount : int = 600
var orig_position : Vector2
var active : bool = false

signal new_ui_scale(amount)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$EditorSettingsBackground/Editor_Settings/UIScale/ColorRect/Right/ResetUIScale.visible = false if $EditorSettingsBackground/Editor_Settings/UIScale/ColorRect/Right/Centered/ScaleAmount.value == 1 else true
	visible = false
	$EditorSettingsBackground.modulate = Color(1,1,1,0)
	orig_position = $EditorSettingsBackground.rect_position
	#load settings
	$EditorSettingsBackground/Editor_Settings/CenteredCoordinates/ColorRect/Right/Centered/CheckBox.pressed = globals.coordinates_centered
	$EditorSettingsBackground/Editor_Settings/Axis/ColorRect/Right/Centered/AxisCheck.pressed = globals.axis_lines
	
	
func _on_CheckBox_toggled(button_pressed) -> void:
	parent.coordinates_centered = button_pressed
	
	
func _on_AxisCheck_toggled(button_pressed) -> void:
	globals.axis_lines = button_pressed
	parent.axis_lines = button_pressed
	
	
func _on_Button_pressed() -> void:
	hide()
	
func hide() -> void:
	active = false
	var tween = $Tween
	var pos = orig_position
	var final_pos = Vector2($EditorSettingsBackground.rect_position.x, $EditorSettingsBackground.rect_position.y + dip_amount)
	tween.interpolate_property($EditorSettingsBackground, "rect_position", pos, final_pos, 1, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
	tween.interpolate_property($EditorSettingsBackground, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
	tween.start()
	yield(tween, "tween_completed")
	visible = false
	
	
func show() -> void:
	visible = true
	active = true
	var tween = $Tween
	var pos = orig_position
	var final_pos = Vector2($EditorSettingsBackground.rect_position.x, $EditorSettingsBackground.rect_position.y + dip_amount)
	tween.interpolate_property($EditorSettingsBackground, "rect_position", final_pos, pos, 1, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
	tween.interpolate_property($EditorSettingsBackground, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
	tween.start()
	
	
func _on_EditorSettings_gui_input(event) -> void:
	if event is InputEventMouseButton and active:
		$EditorSettingsBackground/Button.emit_signal("pressed")
	
	
func _on_Settings_pressed() -> void:
	show()
	
	
func _on_ResetUIScale_pressed():
	$EditorSettingsBackground/Editor_Settings/UIScale/ColorRect/Right/Centered/ScaleAmount.value = 1
	
	
func _on_ScaleAmount_value_changed(value):
	$EditorSettingsBackground/Editor_Settings/UIScale/ColorRect/Right/ScaleAMountNumber.value = value
	$EditorSettingsBackground/Editor_Settings/UIScale/ColorRect/Right/ResetUIScale.visible = true if value != 1 else false
	emit_signal("new_ui_scale", value)
	
	

func _on_ScaleAMountNumber_value_changed(value):
	$EditorSettingsBackground/Editor_Settings/UIScale/ColorRect/Right/Centered/ScaleAmount.value = value
