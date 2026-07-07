extends Node
@onready var http_request = $HTTPRequest


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var url = "https://arizona.app.box.com/shared/static/jnw77jvgtkaux38go9ebt16qvwmsgqzf"
	http_request.request_completed.connect(self._http_request_completed)

	# Perform a GET request. The URL below returns JSON as of writing.
	var error = http_request.request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.",error)


# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	print("request complete",result,response_code,headers)
	var file: FileAccess = FileAccess.open("test.zip", FileAccess.WRITE)
	file.store_buffer(body)
	pass # Replace with function body.
