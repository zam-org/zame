tool
extends Node

# Emitted when a websocket connection to a ZeroNet site completed successfully
signal site_connected
# Emitted when a certain amount of time has passed
signal timeout
# Emitted when a command completes successfully. Returns cmd ID and response data
signal command_completed(response, type)
# Emitted when a site notification is received
signal notification_received(notification)
# Emitted when the site files have been externally updated
signal site_updated(message)

var _daemon_address: String
var _daemon_port: int

var timeout_counter = 0
var timeout_limit = 0

var _wrapper_key: String
var _site_connection_timeout = 1.0
var _site_connected = false
var _ca_addresses = {
	"zeroid": "zeroid.bit"
}
var _ws_client: WebSocketClient
var _wrapper_key_regex: RegEx

var config_file_path = "res://addons/ZeroFrame/config.cfg"
var config = ConfigFile.new()

# Called when a node is instantiated
func _init(config_file=config_file_path, use_config_file=true, daemon_address="127.0.0.1", daemon_port=43110):
	# Attempt to retrieve daemon address and port from config file
	if use_config_file:
		if config.load(config_file) == OK:
			_daemon_address = config.get_value("zeroframe", "daemon_address", daemon_address)
			_daemon_port = int(config.get_value("zeroframe", "daemon_port", daemon_port))
		else:
			print("No address/port specified and config file not available at: ", config_file)
			return
	else:
		# Retrieve daemon information from the constructor
		_daemon_address = daemon_address
		_daemon_port = daemon_port

	# Create a WebSocket client
	_ws_client = new_ws_client()

	# Regex for finding wrapper_key of ZeroNet site
	_wrapper_key_regex = RegEx.new()
	_wrapper_key_regex.compile('wrapper_key = "(.*?)"')

# Called every frame
func _process(delta):
	# Serves as an implementation of timer
	# which doesn't seem to work in this file
	if timeout_limit > 0:
		timeout_counter += delta
		if timeout_counter >= timeout_limit:
			emit_signal("timeout")
			timeout_counter = 0
			timeout_limit = 0

	if _ws_client.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
		_ws_client.poll()
		if _ws_client.get_peer(1).get_available_packet_count() > 0:
			var response = JSON.parse(_ws_client.get_peer(1).get_packet().get_string_from_utf8()).result
			if typeof(response) != TYPE_DICTIONARY:
				return

			# Check if this is a response to a command or a site notification
			var type = response["cmd"]
			match type:
				"notification":
					emit_signal("notification_received", response)
				"response":
					emit_signal("command_completed", {"result": response["result"], "type": type})
				"confirm":
					emit_signal("command_completed", {"result": response["params"], "type": type})
				"setSiteInfo":
					emit_signal("site_updated", response)
				_:
					print("Unknown websocket data received:", response)

# Creates a new WebSocket client
func new_ws_client():
	_ws_client = WebSocketClient.new()

	# Websocket client signals
	_ws_client.connect("connection_established", self, "_ws_connection_established")
	_ws_client.connect("connection_succeeded", self, "_ws_connection_established")
	_ws_client.connect("connection_error", self, "_ws_connection_error")
	_ws_client.connect("server_close_request", self, "_ws_server_close_request")

	return _ws_client

# Searches through a dictionary of users for an auth address
# Helper function for ZeroID registration
func _search_zeroid_users(users, auth_address):
	for username in users:
		var cert = users[username]

		# Old user type
		if cert.begins_with("@"):
			var info = cert.replace("@", "").split(",")
			var cert_file_id = info[0]
			var auth_address_pre = info[1]

			# Quick way to narrow down user match
			if auth_address.begins_with(auth_address_pre):
				var cert_filename = "certs_%s.json" % cert_file_id
				var response = yield(
					cmd("fileGet", {"inner_path": cert_filename}),
					"command_completed"
				)

				cert = JSON.parse(response.result)["certs"][username]
				info = cert.split(",")
				var found_auth_address = info[1]

				if found_auth_address == auth_address:
					return cert
		else:
			# New user type
			var info = cert.split(",")
			var found_auth_address = info[1]

			if found_auth_address == auth_address:
				return cert

	# Did not find cert belonging to auth_address
	return ""

# Retrieve the cert information of a ZeroID user given their auth_address
# Helper function for ZeroID registration
func _get_zeroid_cert(auth_address):
	# Get set of archived ZeroID users
	var response = yield(
		cmd("fileGet", {"inner_path": "data/users_archive.json"}),
		"command_completed"
	)
	var users_json = response.result

	var users = JSON.parse(users_json).result["users"]

	# Get set of latest ZeroID users
	response = yield(
		cmd("fileGet", {"inner_path": "data/users.json"}),
		"command_completed"
	)
	users_json = response.result

	var new_users = JSON.parse(users_json).result["users"]

	# Combine latest and archived user sets together
	for user in new_users:
		var content = new_users[user]
		users[user] = content

	return _search_zeroid_users(users, auth_address)

# Solve the ZeroID challenge question
# Helper function for ZeroID registration
func _solve_zeroid_challenge(challenge):
	# Registering with ZeroID requires both connecting to a
	# centralized server and completing a challenge/response process.
	# A challenge is sent in the form `x*y` to the client, and it
	# must respond with the correct product to be granted a certificate.
	# We carry these steps out in this function
	var numbers = challenge.split("*")
	var num1 = numbers[0].to_int()
	var num2 = numbers[1].to_int()

	return num1 * num2

# Registers with the ZeroID certificate authority.
# Registration uses a centralized server and is IP
# rate-limited.
#
# Registration requires completing a challenge/response process.
# Once complete, ZeroID will sign your cert and insert it into
# ZeroID's site files. It is then up to the client to listen for
# this update and find their new cert, then add it to their zeronet
# daemon using the `certAdd` command.
#
# Be aware that this will disrupt any existing site websocket
# connection, which will need to be re-established if necessary
# TODO: Ability to connect to multiple zites at once?
func register_zeroid(username):
	print("Registering user with ZeroID: ", username)

	var clearnet_reg_site = "zeroid.qc.to"

	# Set ZeroID as the site to use
	var success = yield(use_site(_ca_addresses["zeroid"]), "site_connected")
	if not success:
		return "Unable to connect to ZeroID"

	# Retrieve information from siteInfo
	var response = yield(cmd("siteInfo", {}), "command_completed")
	var site_info = response.result

	# Retrieve current public key/auth address
	var auth_address = site_info["auth_address"]

	# Check if this auth_address has already been registered
	var cert = yield(_get_zeroid_cert(auth_address), "completed")
	if cert != "":
		# This user has already been registered
		var info = cert.split(",")
		var auth_type = info[0]
		var cert_sign = info[2]

		# Add cert to the client
		response = yield(cmd("certAdd", {
			"domain": _ca_addresses["zeroid"],
			"auth_type": auth_type,
			"auth_user_name": username,
			"cert": cert_sign,
		}), "command_completed")

		print("This user already exists:", response)

		if response.type == "confirm":
			# We already have a cert for this registrar
			# TODO: Replace existing cert
			return null
		else:
			if response.result == "OK":
				return null
			else:
				return response.result

	# Set up registration data to send to challenge server
	var registration_data = {
		"auth_address": auth_address,
		"user_name": username,
	}
	print("Registering (1/2) with: ", JSON.print(registration_data))

	# Get challenge
	var request = _make_http_request(clearnet_reg_site,
										80,
										"/ZeroID/request.php",
										registration_data,
										HTTPClient.METHOD_POST)

	if request.error != null:
		print("Unable to connect to", clearnet_reg_site)

	response = JSON.parse(request.data)
	if response.error != OK:
		# Received an error instead of data
		# Give up and return error
		return "Non-JSON data received from " + clearnet_reg_site + ": " + request.data

	response = response.result

	# Response is in the form {"work_id":xxx,"work_task":"y*z"}
	# Add work_id and task solution to registration data and send
	# back to host
	registration_data["work_id"] = response["work_id"]
	registration_data["work_solution"] = _solve_zeroid_challenge(response["work_task"])
	print("Registering (2/2) with: ", JSON.print(registration_data))

	# Send challenge solution
	request = _make_http_request("zeroid.qc.to",
								80,
								"/ZeroID/solution.php",
								registration_data,
								HTTPClient.METHOD_POST).data

	if request.error != null:
		print("Unable to connect to", clearnet_reg_site)

	# Ensure registration was successful
	if request.data != "OK":
		# Not successful, return reason
		return response

	# Wait for notification of site update
	print("Waiting for site updated")
	print("Site updated: ", yield(self, "site_updated"))
	print("Updated!")

	# Retrieve cert information from ZeroID site files
	cert = _get_zeroid_cert(auth_address)

	var info = cert.split(",")
	var auth_type = info[0]
	var cert_sign = info[2]

	# Add cert to the client
	response = yield(cmd("certAdd", {
		"domain": _ca_addresses["zeroid"],
		"auth_type": auth_type,
		"auth_user_name": username,
		"cert": cert_sign,
	}), "command_completed")

	# Registration completed and new cert added to client
	match response.type:
		"confirm":
			# We already have a cert for this registrar
			# TODO: Replace existing cert
			return null
		"response":
			if response == "OK":
				return null
			else:
				return response

# Make a http/s request to a host.
# payload is a string that will be sent in the request
func _make_http_request(host, port, path, payload, method_type=HTTPClient.METHOD_GET):
	var err = 0
	var http = HTTPClient.new() # Create the Client
	var response = {"data": "", "error": null}

	err = http.connect_to_host(host, port, port == 443) # Connect to host/port
	assert(err == OK) # Make sure connection was OK

	# Wait until resolved and connected
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		OS.delay_msec(300)

	if http.get_status() != HTTPClient.STATUS_CONNECTED:
		# Could not connect
		response.error = "Unable to connect to host"
		return response

	# Different headers for POST vs. GET
	var headers = ["User-Agent: Pirulo/1.0 (Godot)"]
	if method_type == HTTPClient.METHOD_GET:
		headers.append("Accept: text/html")
	elif method_type == HTTPClient.METHOD_POST:
		headers.append("Accept: */*")
		headers.append("Content-Type: application/x-www-form-urlencoded; charset=UTF-8")
		payload = http.query_string_from_dict(payload)

	# Request a page from the site (this one was chunked..)
	err = http.request(method_type, path, headers, payload)
	if err != OK:
		response.error = "Unable to request data from site"
		return response

	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling while the request is ongoing
		http.poll()
		OS.delay_msec(500)

	if http.get_status() != HTTPClient.STATUS_BODY and http.get_status() != HTTPClient.STATUS_CONNECTED: # Make sure request finishes
		response.error = "Request finished prematurely"
		return response

	if http.has_response():
		headers = http.get_response_headers_as_dictionary() # Get response headers

		# Getting the HTTP Body
		var rb = PoolByteArray() # Array that will hold the data

		while http.get_status() == HTTPClient.STATUS_BODY:
			# While there is body left to be read
			http.poll()
			var chunk = http.read_response_body_chunk() # Get a chunk
			if chunk.size() == 0:
				# Got nothing, wait for buffers to fill a bit
				OS.delay_usec(1000)
			else:
				rb = rb + chunk # Append to read buffer

		response.data = rb.get_string_from_ascii()
		return response

	return "No response"

# Get available certs that the current site supports
func get_available_certs():
	# TODO: Get certs through selectCert. HTML processing for now
	pass

# Select a cert given by get_available_certs
func select_cert(id):
	# TODO: Send a response from _ws_client with the chosen cert
	pass

# Retrieve the wrapper_key of a ZeroNet website
func get_wrapper_key(site_address):
	# Get webpage text containing wrapper key
	var request = _make_http_request(_daemon_address, _daemon_port, "/" + site_address, "")
	if request.error != null:
		print("Got error with retrieving wrapper_key: ", request.error)
		return ""

	var text = request.data

	# Parse text and grab wrapper key
	var matches = _wrapper_key_regex.search(text)

	# Check that we got a match on the wrapper_key
	if matches == null or matches.get_group_count() == 0:
		return ""

	# Return the wrapper_key
	return matches.get_string(1)

# Send a command to the ZeroNet daemon
func cmd(command, parameters):
	# Send command with arguments to ZeroNet daemon over websocket
	var contents = JSON.print({"cmd": command, "params": parameters, "id": 1000001})
	print("Sending command:", contents)
	_ws_client.get_peer(1).put_packet(contents.to_utf8())

	return self

# Set custom zeronet daemon host address and port
func set_daemon(host, port):
	_daemon_address = host
	_daemon_port = port

# Calls site_connected after a certain amount of seconds
func _site_connect_timeout():
	timeout_limit = _site_connection_timeout
	yield(self, "timeout")
	if not _site_connected:
		emit_signal("site_connected", false)

# Use this site for future commands
func use_site(site_address):
	print("Connecting to: ", _daemon_address, ":", _daemon_port)

	# Remove any previous websocket connection
	if _ws_client != null:
		_ws_client.disconnect_from_host()

	_ws_client = new_ws_client()
	_site_connected = false

	# Set timeout timer
	_site_connect_timeout()

	# Get wrapper key of the site
	_wrapper_key = get_wrapper_key(site_address)

	if _wrapper_key == "":
		print("Unable to connect to ZeroNet")
		return self

	# Open up WebSocket connection to the daemon
	var ws_url = "ws://" + _daemon_address + ":" \
		+ str(_daemon_port) \
		+ "/Websocket?wrapper_key=%s" % _wrapper_key

	_ws_client.connect_to_url(ws_url)

	return self

func _connection_established(established):
	if not _site_connected:
		_site_connected = true
		emit_signal("site_connected", established)

func _ws_connection_established(protocol):
	print("Connection established with protocol %s!" % protocol)
	# Set sending websocket data as text, which ZeroNet prefers, rather than binary
	_ws_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)

	_connection_established(true)

func _ws_connection_error():
	print("Websocket connection failed!")

func _ws_server_close_request(error, reason):
	print("Server issued close request!", error, reason)

# Herp derp!
func _be_external_program():
	var site_address = "1vcpDyMSZWDMmsD81Z6zApFStPvr2j728"
	var username = "tespusper7"
	var error = yield(register_zeroid(username), "completed")
	if error == null:
		print("Successful!")
	else:
		print("Unable to successfully register: ", error)
		return

	# Open a connection to a ZeroNet site
	if not yield(use_site(site_address), "site_connected"):
		print("Unable to connect to site")
		return

	# Get available users
	#var users = get_users()

	# Send siteInfo command to retrieve information about the site
	var site_info = yield(cmd("siteInfo", {}), "command_completed").result

	# Store some data on the site
	var inner_path = "data/%s/data.json" % site_info["auth_address"]
	var data = Marshalls.utf8_to_base64(JSON.print({"score": 500}))
	var response = yield(cmd("fileWrite", {"inner_path": inner_path, "content_base64": data}), "command_completed")
	print("Store response: ", response)

	# Publish the data to peers
	response = yield(cmd("sitePublish", {"sign": true}), "command_completed")

	# Retrieve that data
	response = yield(cmd("fileGet", {"inner_path": inner_path}), "command_completed")
	var user_data = JSON.parse(response.result)
	print(user_data.result)

