extends ColorRect

var active : bool = false
var block

var dangerous = 0
var logic = 0
var direction : Vector2 = Vector2.UP
var rot_speed : float
var rotation : int
var rate_of_fire : float

func _ready():
	self.visible = false

	$MarginContainer/HBoxContainer/Logic/Left.clear()
	$MarginContainer/HBoxContainer/Logic/Left.add_item("Left")
	$MarginContainer/HBoxContainer/Logic/Left.add_item("Right")
	$MarginContainer/HBoxContainer/Logic/Left.add_item("Bounce")
	
	$MarginContainer/HBoxContainer/Direction/Direction.clear()
	$MarginContainer/HBoxContainer/Direction/Direction.add_item("Up")
	$MarginContainer/HBoxContainer/Direction/Direction.add_item("Left")
	$MarginContainer/HBoxContainer/Direction/Direction.add_item("Right")
	$MarginContainer/HBoxContainer/Direction/Direction.add_item("Down")
	
	$MarginContainer/HBoxContainer/ROF/RateOfFire.clear()
	$MarginContainer/HBoxContainer/ROF/RateOfFire.add_item("Slow")
	$MarginContainer/HBoxContainer/ROF/RateOfFire.add_item("Medium")
	$MarginContainer/HBoxContainer/ROF/RateOfFire.add_item("Fast")
	
	$MarginContainer/HBoxContainer/Rotation/Rotation.clear()
	$MarginContainer/HBoxContainer/Rotation/Rotation.add_item("None")
	$MarginContainer/HBoxContainer/Rotation/Rotation.add_item("Right")
	$MarginContainer/HBoxContainer/Rotation/Rotation.add_item("Left")
	
	$MarginContainer/HBoxContainer/RotSpeed/RotSpeed.clear()
	$MarginContainer/HBoxContainer/RotSpeed/RotSpeed.add_item("Slow")
	$MarginContainer/HBoxContainer/RotSpeed/RotSpeed.add_item("Medium")
	$MarginContainer/HBoxContainer/RotSpeed/RotSpeed.add_item("Fast")
	
	
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
		if node is KinematicBody2D or node is StaticBody2D:
			for i in $MarginContainer/HBoxContainer.get_children():
				i.visible = false
			block = node
			print(block.type)
			if block.type == "Moving":
				$MarginContainer/HBoxContainer/Logic.visible = true
				$MarginContainer/HBoxContainer/Soft.visible = true
				$MarginContainer/HBoxContainer/Direction.visible = true

				
			elif block.type == "Turret":
				$MarginContainer/HBoxContainer/ROF.visible = true
				$MarginContainer/HBoxContainer/Rotation.visible = true
				$MarginContainer/HBoxContainer/RotSpeed.visible = true
				$MarginContainer/HBoxContainer/Direction.visible = true												

			else:
				$MarginContainer/HBoxContainer/Logic.visible = true
				$MarginContainer/HBoxContainer/Direction.visible = true
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
	block.logic = ID
	logic = ID


func _on_Rotation_item_selected(ID):
	print("Block rotating is set to: ", ID)
	block.rotating = ID
	rotation = ID


func _on_RateOfFire_item_selected(ID):
	var rof : float
	match ID:
		0:
			rof = 3
		1:
			rof = ID
		2:
			rof = 0.6
			
	block.rate_of_fire = rof
	rate_of_fire = rof

func _on_RotSpeed_item_selected(ID):
	var speed : float
	match ID:
		0:
			speed = 0.5
		1:
			speed = 1.0
		2:
			speed = 2.0
	block.rotate_speed = speed
	rot_speed = speed

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
			
	block.desired_direction = direction

func set_enemy_style():
	block.desired_direction = direction
	if block.type == "Turret":
		block.rotate_speed = rot_speed
		block.rate_of_fire = rate_of_fire
		block.rotating = rotation
		return
	block.logic = logic

func _on_SoftToggle_pressed():
	if block.type == "Moving":
		block.soft = $MarginContainer/HBoxContainer/Soft/CenterContainer/SoftToggle.pressed