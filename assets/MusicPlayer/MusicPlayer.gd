extends ColorRect

var original_location : Vector2
var main_btn_size : Vector2
var playing : bool

var pause_icon : Texture = preload("res://ui/icons/pause-circle.svg")
var play_icon : Texture = preload("res://ui/icons/play-circle.svg")
var extended : = false
var hidden : = false

var paused_at : float 

var song_list : Array
var artist_list : Array

var current_song : int = 0

func _ready():
	$IdleTime.start()
	original_location = rect_position
	main_btn_size = $HBoxContainer/Centered.rect_size
	
	for i in $Songs.get_children():
		artist_list.append(i)
		
	yield(get_tree().create_timer(0.1), "timeout")
		
	for artist in artist_list:
		for song in artist.get_children():
			song_list.append(song)
	
	for i in song_list:
		if !i is AudioStreamPlayer:
			song_list.remove(song_list.find(i))
			
	yield(get_tree().create_timer(0.1), "timeout")
			
	print(song_list)
	song_list.shuffle()
	play_song()

func play_song() -> void:
	playing = true
	song_list[current_song].play()
	$HBoxContainer/Vertical/SongInfo.text = song_list[current_song].name + " - " + song_list[current_song].get_parent().name

func update_orig_loc() -> void:
	rect_position.x = OS.get_real_window_size().x - $HBoxContainer/Centered.rect_size.x
	original_location = rect_position 

func show():
	var length = $HBoxContainer.rect_size.x
	var final = Vector2(original_location.x - length, original_location.y)
	$Tween.interpolate_property(self, 'rect_position', original_location, final, 1, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
	$Tween.start()
	extended = true
	
func hide():
	var length = $HBoxContainer/Vertical.rect_size.x
	var final = Vector2(original_location.x - length, original_location.y)
	$Tween.interpolate_property(self, 'rect_position', rect_position, original_location, 1, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
	$Tween.start()
	extended = false

func pop_out():
	$Tween.interpolate_property(self, 'rect_position', rect_position, original_location, 1, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
	$Tween.start()
	extended = false
	hidden = false

func pop_in():
	var length = $HBoxContainer/Centered.rect_size.x / 2
	var final = Vector2(original_location.x + length, original_location.y)
	$Tween.interpolate_property(self, 'rect_position', rect_position, final, 1, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
	$Tween.start()
	extended = false
	hidden = true

func _on_IdleTime_timeout():
	pop_in()
	
	
func _on_MusicPlayerButton_pressed():
	if !extended:
		show()
	else:
		hide()

func _on_Play_pressed():
	if playing:
		playing = false
		paused_at = song_list[current_song].get_playback_position()
		song_list[current_song].stop()
		$HBoxContainer/Vertical/Horizontal/Play.texture_normal = play_icon
	else:
		playing = true
		song_list[current_song].play(paused_at)
		$HBoxContainer/Vertical/Horizontal/Play.texture_normal = pause_icon


#when mouse exits the timer starts and closes the music player three seconds later
func _on_HBoxContainer_mouse_entered():
	if hidden:
		pop_out()
	$IdleTime.stop()
	
	
func _on_HBoxContainer_mouse_exited():
	$IdleTime.start()
	
	

func _on_Rewind_pressed():
	song_list[current_song].stop()
	if (current_song) > 0:
		current_song -= 1
	else:
		current_song = song_list.size() - 1
	play_song()
	print(current_song)


func _on_FastForward_pressed():
	song_list[current_song].stop()
	if (current_song + 1) < song_list.size():
		current_song += 1
	else:
		current_song = 0
	play_song()
	print(current_song)
