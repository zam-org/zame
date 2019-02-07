extends CanvasLayer

var play : bool = false

var details_on : bool = false

func _ready():
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
	
	if $Details.visible:
		details_on = true
		$Details.visible = false
	
func deactivate():
	set_process_input(false)
	play = false
	$ItemList.visible = true
	$Esc.visible = false
	
	if details_on:
		$Details.visible = true
		details_on = false

func _on_Save_pressed():
	pass # Replace with function body.
