extends TextureButton

func _on_SimpleTextureButton_mouse_entered():
	modulate = Color(1,1,1,1)

func _on_SimpleTextureButton_mouse_exited():
	modulate = Color(1,1,1,0.3)