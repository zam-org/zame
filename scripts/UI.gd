extends CanvasLayer

var global_mouse_pos : Vector2
var cam_pos : Vector2

var toolbar_orig_pos : Vector2

var play : bool = false
var details_on : bool = false
var hidden_tools : bool = false

func _ready():
	toolbar_orig_pos = $ItemList.rect_position
	$Esc.visible = false
	set_process_input(false)	

func _input(event):
	if event.as_text() == "Escape":
		get_tree().call_group("play", "deactivate")
		
func opacity(on : bool = false):
	$ItemList.visible = on

func activate():
	set_process_input(true)
	play = true
	$ItemList.visible = false
	$Esc.visible = true
	$Lines.visible = false
	$ZoomContainer.visible = false
	
	if $Details.visible:
		details_on = true
		$Details.visible = false
	
func deactivate():
	set_process_input(false)
	play = false
	$ItemList.visible = true
	$Esc.visible = false
	$Lines.visible = true
	$ZoomContainer.visible = true
	
	if details_on:
		$Details.visible = true
		details_on = false


func _on_Upload_pressed():
	$PublishLevelPopUp.visible = true

func _process(delta):
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	# move the lines according to the mouse's X and Y
	# this happens in the local coordinate system of the 
	# viewport
	$Lines/X.rect_position.x = mouse_pos.x
	$Lines/Y.rect_position.y = mouse_pos.y
	
	# move the hide toggle button and it's background with the mouse
	# only the the Y axis though
	$ItemList/HideShow.rect_position.y = mouse_pos.y - $ItemList/HideShow.rect_size.y / 2
	
	# a snapped global mouse pos, worked fine but I am not sure whether it's better
	# cos' you see it's kinda cool to see the values go up and down like crazy
	
#	var snapped_mouse_pos = global_mouse_pos.snapped(Vector2(20,20))
	
	# update the labels' text ofr X and Y
	$Lines/Y/YAmount.text = "Y: " + str(ceil(global_mouse_pos.y * -1))
	$Lines/X/XAmount.text = "X: " + str(ceil(global_mouse_pos.x))


func _on_level_block_built():
	$Tween.interpolate_property($Lines, "modulate", Color(1,0.64,0.1,0.9), Color(1,1,1,0.4), 1, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
	$Tween.start()


func _on_Camera_cam_pos(pos, mouse_pos):
	cam_pos = pos
	global_mouse_pos = mouse_pos


func _on_HideShowButton_pressed():
	var hidden_pos : Vector2 = Vector2(toolbar_orig_pos.x - $ItemList.rect_size.x, toolbar_orig_pos.y)
	if !hidden_tools:
		$Tween.interpolate_property($ItemList, "rect_position", toolbar_orig_pos, hidden_pos, 0.7, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
		$ItemList/HideShow/HideShowButton.text = ">"
		hidden_tools = true
		
	else:
		$Tween.interpolate_property($ItemList, "rect_position", hidden_pos, toolbar_orig_pos, 0.7, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
		$ItemList/HideShow/HideShowButton.text = "<"
		hidden_tools = false
		
	$Tween.start()


func _on_MagnifyingGlassPlus_pressed():
	$ZoomContainer/CenterContainer/MagnifyAmount.value += $ZoomContainer/CenterContainer/MagnifyAmount.step


func _on_MagnifyingGlassMinus_pressed():
	$ZoomContainer/CenterContainer/MagnifyAmount.value -= $ZoomContainer/CenterContainer/MagnifyAmount.step
