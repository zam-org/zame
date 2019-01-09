extends Control

onready var map_list : ItemList = $SidePanelSpace/SidePanel/MapList

const MIN_MAP_LIST_SIZE = 95
const MAX_MAP_LIST_SIZE = 300

func _ready():
	set_process_input(false)

func _input(event):
	if event is InputEventMouseButton:
		#	show mouse and stop listening to input when LMB is unclicked
		if event.button_index == 1 and !event.pressed:
#			Input.warp_mouse_position($SidePanelSpace/SidePanel/grab_container/GrabMe.rect_global_position)
			Input.set_mouse_mode(0)
			var new_mouse_pos = $SidePanelSpace/SidePanel/grab_container/GrabMe.rect_global_position
			new_mouse_pos.x += $SidePanelSpace/SidePanel/grab_container/GrabMe.rect_size.x / 2
			new_mouse_pos.y += $SidePanelSpace/SidePanel/grab_container/GrabMe.rect_size.y / 2			
			Input.warp_mouse_position(new_mouse_pos)
			set_process_input(false)

	elif event is InputEventMouseMotion:
	#	listen to mouse speed and apply it to the rectangle size
	#	ONLY if the change in size is within limits
		var change = event.relative.y
		if map_list.rect_min_size.y + change > MIN_MAP_LIST_SIZE and map_list.rect_min_size.y + change < MAX_MAP_LIST_SIZE:
			map_list.rect_min_size.y += change
			$SidePanelSpace/SidePanel.queue_sort()

func _on_GrabMe_pressed():
	set_process_input(true)
	Input.set_mouse_mode(2)

func play_click() -> void:
	$click.play()