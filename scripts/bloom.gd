extends ColorRect

func bloom(strength, duration, bloom = false, bloom_strength = 4):
	var mat = self.material
	$tween.interpolate_property(mat, 'shader_param/hdr_threshold', strength, 1.5, duration, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$tween.interpolate_property(mat, 'shader_param/bloom', bloom_strength, 5.06, duration, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$tween.start()

func _on_character_coin():
	bloom(0.8, 2)


func _on_character_death():
	bloom(0.1, 5, true, 20)
