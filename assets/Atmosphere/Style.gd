extends Control

signal selected(style)

func appear() -> void:
	visible = true

func dissappear() -> void:
	visible = false

func _on_Black_gui_input(event) -> void:
	if event is InputEventMouseButton:
		dissappear()


func _on_Normal_pressed() -> void:
	emit_signal("selected", 0)
	dissappear()

func _on_DigitalFog_pressed() -> void:
	emit_signal("selected", 1)
	dissappear()

func _on_Darkness_pressed() -> void:
	emit_signal("selected", 2)
	dissappear() 

