extends Node3D

func _ready() -> void:
	var success = ProjectSettings.load_resource_pack("res://all_anims_test.pck")
	if success:
		var anim = load("res://animatedFrames_packed.tres")
		$AnimatedSprite3D.sprite_frames = anim
		$AnimatedSprite3D.play("gifanimation")
