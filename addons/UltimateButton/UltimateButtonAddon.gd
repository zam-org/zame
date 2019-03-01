tool
extends EditorPlugin



func _enter_tree():
	add_custom_type("UltimateButton", "TextureButton", load("res://addons/UltimateButton/UltimateButton.gd"), load("res://addons/UltimateButton/Icon.png"))

func _exit_tree():
	# Erase the control from the memory
	remove_custom_type("UltimateButton")

