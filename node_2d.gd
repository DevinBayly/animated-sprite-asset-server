extends Node2D

@onready var Vbox = $VBoxContainer

var responses_csv_link = "https://docs.google.com/spreadsheets/d/e/2PACX-1vR8XG3cyWfHo2yXya28fyQCwO2b8hf-5zdqwH_Vkss9BmTwwri-qgflD2ZowyxYufrDLFN0EaMQxi22/pub?output=csv"
# redirection link 
signal responseGrab
signal makeResources


func _on_response_grabber_pressed() -> void:
	responseGrab.emit()

func make_resource_grabber_button(pnames):
	for pname in pnames:
		var new_button = Button.new()
		new_button.text = pname
		new_button.pressed.connect(request_project_assets_packaged_as_resources.bind(pname))
		Vbox.add_child(new_button)

func request_project_assets_packaged_as_resources(pname):
	makeResources.emit(pname)
