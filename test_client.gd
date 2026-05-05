extends Node

signal projectNames

func response_request():
	$networking.issue_form_response_request.rpc()

func _on_networking_project_names(pnames) -> void:
	projectNames.emit(pnames)
	pass # Replace with function body.
