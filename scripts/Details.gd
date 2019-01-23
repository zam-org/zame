extends ColorRect

var active : bool = false
var block : KinematicBody2D

var dangerous = 0
var left = 1
var direction : Vector2 = Vector2.UP

func _ready():
	self.visible = false
	
	$MarginContainer/HBoxContainer/PlatformOptions.clear()
	$MarginContainer/HBoxContainer/PlatformOptions.add_item("Platform")
	$MarginContainer/HBoxContainer/PlatformOptions.add_item("Enemy")	

	$MarginContainer/HBoxContainer/Left.clear()
	$MarginContainer/HBoxContainer/Left.add_item("Left")
	$MarginContainer/HBoxContainer/Left.add_item("Right")	
	
	$MarginContainer/HBoxContainer/Direction.clear()
	$MarginContainer/HBoxContainer/Direction.add_item("Up")
	$MarginContainer/HBoxContainer/Direction.add_item("Left")
	$MarginContainer/HBoxContainer/Direction.add_item("Right")
	$MarginContainer/HBoxContainer/Direction.add_item("Down")		
	
func activate():
	active = true
	self.visible = true
	$Tween.interpolate_property(self, "modulate", modulate, Color(1,1,1,1), 0.4, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.start()
	set_enemy_style()

func deactivate():
	active = false
	$Tween.interpolate_property(self, "modulate", modulate, Color(1,1,1,0), 0.4, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.start()
	yield($Tween, 'tween_completed')
	if active == false:
		self.visible = false

func _on_level_on_enemy_selected(yes, node):
	if yes:
		if node is KinematicBody2D:
			block = node
			activate()
		else:
			print("Selected node is not the enemy type")
	else:
		block = null
		deactivate()

func _on_PlatformOptions_item_selected(ID):
	if ID == 0:
		block.dangerous = false
		dangerous = 0
	else:
		block.dangerous = true
		dangerous = 1


func _on_Left_item_selected(ID):
	if ID == 0:
		block.left = true
		left = 1
	else:
		block.left = false
		left = 0

# Directions
# 0 - UP
# 1 - LEFT
# 2 - RIGHT
# 3 - DOWN

func _on_Direction_item_selected(ID):
	match ID:
		0:
			direction = Vector2.UP
		1:
			direction = Vector2.LEFT
		2:
			direction = Vector2.RIGHT
		3:
			direction = Vector2.DOWN
			
	block.direction = direction

func set_enemy_style():
	print(dangerous, left)
	block.dangerous = true if dangerous else false
	block.left = true if left else false
	block.direction = direction