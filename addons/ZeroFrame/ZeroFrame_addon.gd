tool
extends EditorPlugin

var dock

func _enter_tree():
	add_custom_type("ZeroFrame", "Node", load("res://addons/ZeroFrame/ZeroFrame.gd"), load("res://addons/ZeroFrame/icon.png"))
	
	dock = preload("res://addons/ZeroFrame/ZeroFrame_ui.tscn").instance()

	# Add the loaded scene to the docks
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	dock.refresh_values()

func _exit_tree():
	remove_control_from_docks(dock)
	# Erase the control from the memory
	remove_custom_type("ZeroFrame")
#	dock.queue_free()
