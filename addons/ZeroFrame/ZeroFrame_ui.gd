tool
extends Node

var config_file_path= "res://addons/ZeroFrame/config.cfg"
var config = ConfigFile.new()

var zeroFrame = preload("ZeroFrame.gd").new(config_file_path)

func _process(delta):
	# Check if zeroFrame is initialized yet
	if zeroFrame.has_method("_process"):
		zeroFrame._process(delta)

func _ready():
	# Load config file
	var err = config.load(config_file_path)

	# If the config file has yet to exist
	if err != OK:
		print(OK)

		# File does not exist yet, create it
		print("Creating initial config file")
		config.save(config_file_path)
	# if it does exist we load the values
	else:
		$VBoxContainer/site_address_edit.text = load_setting("zeroframe", "site_address", "")
		$VBoxContainer/zeronet_address_edit.text = load_setting("zeroframe", "zeronet_address", "127.0.0.1")
		$VBoxContainer/zeronet_port_edit.text = load_setting("zeroframe", "zeronet_port", "43110")
		$VBoxContainer/center/HBoxContainer/max_in.text = load_setting("zeroframe", "max_in_buffer_kb", "64")
		$VBoxContainer/center/HBoxContainer/max_out.text = load_setting("zeroframe", "max_out_buffer_kb", "64")
		$VBoxContainer/automatic_limit.pressed = load_setting("zeroframe", "automatic_buffer_kb", false)
		if load_setting("zeroframe", "automatic_buffer_kb", false):
			$VBoxContainer/center/HBoxContainer/max_in.editable = false
			$VBoxContainer/center/HBoxContainer/max_out.editable = false

func refresh_values():
	# TODO: Get version from the plugin.cfg instead
	$VBoxContainer/CenterContainer/HBoxContainer/version.text = str(load_setting("zeroframe", "version", "v 0.0.1"))

	# Get the WebSocket buffer sizes and save them
	var new_in = load_setting("zeroframe", "max_in_buffer_kb", ProjectSettings.get_setting("network/limits/websocket_client/max_in_buffer_kb"))
	var new_out = load_setting("zeroframe", "max_out_buffer_kb", ProjectSettings.get_setting("network/limits/websocket_client/max_out_buffer_kb"))
	ProjectSettings.set_setting("network/limits/websocket_client/max_in_buffer_kb", new_in)
	ProjectSettings.set_setting("network/limits/websocket_client/max_out_buffer_kb", new_out)

	# Update text based on the config file
	$VBoxContainer/center/HBoxContainer/max_in.text = str(ProjectSettings.get_setting("network/limits/websocket_client/max_in_buffer_kb"))
	$VBoxContainer/center/HBoxContainer/max_out.text = str(ProjectSettings.get_setting("network/limits/websocket_client/max_out_buffer_kb"))
	$VBoxContainer/site_address_edit.text = load_setting("zeroframe", "site_address", "1HeLLo4uzjaLetFx6NH3PMwFP3qbRbTf3D")
	$VBoxContainer/zeronet_address_edit.text = load_setting("zeroframe", "zeronet_address", "127.0.0.1")
	$VBoxContainer/zeronet_port_edit.text = str(load_setting("zeroframe", "zeronet_port", 43110))
	$VBoxContainer/center/HBoxContainer/max_in.text = str(ProjectSettings.get_setting("network/limits/websocket_client/max_in_buffer_kb"))
	$VBoxContainer/center/HBoxContainer/max_out.text = str(ProjectSettings.get_setting("network/limits/websocket_client/max_out_buffer_kb"))

	zeroFrame.set_daemon($VBoxContainer/zeronet_address_edit.text, int($VBoxContainer/zeronet_port_edit.text))

func _on_site_address_edit_text_changed(address):
	save_setting("zeroframe", "site_address", address)

func _on_zeronet_address_edit_text_changed(address):
	save_setting("zeroframe", "zeronet_address", address)
	zeroFrame.set_daemon(address, int($VBoxContainer/zeronet_port_edit.text))

func _on_zeronet_port_edit_text_changed(port):
	var int_port = int(port)
	zeroFrame.set_daemon($VBoxContainer/zeronet_address_edit.text, int_port)
	save_setting("zeroframe", "zeronet_port", port)

func _on_check_button_pressed():
	# Inform user that the connection is being checked
	$VBoxContainer2/CenterContainer2/connection_status.text = "Checking connection..."

	# Connect to site. Complain if timeout reached
	if yield(zeroFrame.use_site($VBoxContainer/site_address_edit.text), "site_connected"):
		$VBoxContainer2/CenterContainer2/connection_status.text = "Connection successful!"
	else:
		$VBoxContainer2/CenterContainer2/connection_status.text = "Connection timed out"

func _on_buffer_kb_button_pressed():
	# Show explanation of WebSocket buffer setting
	$VBoxContainer/buffer_explanation.visible = !$VBoxContainer/buffer_explanation.visible

func _on_automatic_limit_toggled(button_pressed):
	# Runs when automatic WebSocket limit handling is toggled
	if button_pressed:
		$VBoxContainer/center/HBoxContainer/max_in.editable = false
		$VBoxContainer/center/HBoxContainer/max_out.editable = false
		save_setting("zeroframe", "automatic_buffer_kb", true)
	else:
		$VBoxContainer/center/HBoxContainer/max_in.editable = true
		$VBoxContainer/center/HBoxContainer/max_out.editable = true
		save_setting("zeroframe", "automatic_buffer_kb", false)

func _on_max_in_text_changed(new_in_limit):
	ProjectSettings.set_setting("network/limits/websocket_client/max_in_buffer_kb", new_in_limit)
	save_setting("zeroframe", "max_in_buffer_kb", new_in_limit)

func _on_max_out_text_changed(new_out_limit):
	ProjectSettings.set_setting("network/limits/websocket_client/max_out_buffer_kb", new_out_limit)
	save_setting("zeroframe", "max_out_buffer_kb", new_out_limit)

func save_setting(section, key, value):
	config.set_value(section, key, value)
	config.save(config_file_path)

func load_setting(section, key, default):
	return config.get_value(section, key, default)

func reset_to_defaults():
	save_setting("zeroframe", "site_address", "1HeLLo4uzjaLetFx6NH3PMwFP3qbRbTf3D")
	save_setting("zeroframe", "zeronet_address", "127.0.0.1")
	save_setting("zeroframe", "zeronet_port", 43110)
	save_setting("zeroframe", "max_in_buffer_kb", 16)
	save_setting("zeroframe", "max_out_buffer_kb", 16)
	refresh_values()

func _on_defaults_button_pressed():
	reset_to_defaults()
