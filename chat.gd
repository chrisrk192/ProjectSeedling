class_name Chat
extends PanelContainer

@export var url = "http://127.0.0.1:11434/api/generate"
@export var userData: TextEdit
@export var chatText: RichTextLabel
var chatData = ChatData.new()
var headers = ["Content-Type: application/json"]
var http = HTTPClient.new()

func _ready() -> void:
	chatData.model = "llama3.2"
	chatData.system = "You're a cat. Don't repeat the same cat-like action too often"
	chatData.prompt = "Hello there llama!"
	chatData.stream = true
	# Connect to the host
	IP.resolve_hostname(url, IP.TYPE_IPV4)
	var err = http.connect_to_host("127.0.0.1", 11434, null)
	if err != OK:
		print("Failed to connect to host: ", err)
		return
	# Wait until resolved and connected
	while http.get_status() in [HTTPClient.STATUS_CONNECTING, HTTPClient.STATUS_RESOLVING]:
		http.poll()
		await get_tree().process_frame
	if http.get_status() != HTTPClient.STATUS_CONNECTED:
		print("Unable to connect.")
		return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("send"):
		chatData.prompt = userData.text
		chatText.text += "\n" + userData.text + "\n"
		userData.text = ""
		# Send the request
		var request_body = JSON.stringify(chatData.to_dict())
		var err = http.request(HTTPClient.METHOD_POST, "/api/generate", headers, request_body)
		if err != OK:
			print("Failed to send request: ", err)
			return
		# Process the response
		while http.get_status() == HTTPClient.STATUS_REQUESTING:
			http.poll()
			await get_tree().process_frame
		if not http.has_response():
			print("No response received.")
			return
		# Read the response body in chunks
		var response_data = PackedByteArray()
		while http.get_status() == HTTPClient.STATUS_BODY:
			http.poll()
			var chunk = http.read_response_body_chunk()
			if chunk.size() == 0:
				await get_tree().process_frame
			else:
				response_data += chunk
				var response_text: String = JSON.parse_string(chunk.get_string_from_utf8())["response"]
				if(response_text.contains("\n")):
					print("new paragraph")
				chatText.text += response_text
				token_recieved.emit(response_text)
		# Process the complete response
		#var response_text = response_data.get_string_from_utf8()
		#print(response_text)
		#var json = JSON.parse_string(response_text)
		#if json.error == OK:
			#chatText.text += json.result["response"]
		#else:
			#print("Failed to parse JSON response.")
			
signal token_recieved(String)
