extends Node3D
@onready var client = $networking
@onready var UI = $Node2D
func _ready() -> void:
	
	pass


func _on_node_2d_response_grab() -> void:
	client.issue_form_response_request.rpc()
	pass # Replace with function body.



func _on_test_client_project_names(pnames) -> void:
	UI.make_resource_grabber_button(pnames)
	pass # Replace with function body.


func _on_node_2d_make_resources(pname) -> void:
	# send rpc back to server to ask for specific project packaged up
	client.retrieve_gifs.rpc(pname)
	pass # Replace with function body.


func _on_networking_pck_ready(pckName) -> void:
	var success = ProjectSettings.load_resource_pack("res://"+pckName)
	if success:
		var anim = load("res://animatedFrames.tres")
		$AnimatedSprite3D.sprite_frames = anim
		$AnimatedSprite3D.play("gifanimation")
	pass # Replace with function body.
