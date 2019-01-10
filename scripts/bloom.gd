extends ColorRect

func bloom():
	var mat = self.material
	$tween.interpolate_property(mat, 'shader_param/hdr_threshold', 0.8, 1.5, 2, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$tween.start()

func _on_character_coin():
	bloom()
