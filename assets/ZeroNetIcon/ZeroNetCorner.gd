extends Control

signal clicked

func _on_TextureButton_pressed():
	emit_signal("clicked")
