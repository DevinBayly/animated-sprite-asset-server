extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_unzipper_pck_made() -> void:
	
	var success = ProjectSettings.load_resource_pack("user://all_anims_test.pck")
	print("success," , success)
	if success:
		var dir= DirAccess.open("res://woman_pck/")
		var sframes = SpriteFrames.new()
		var i=0
		for file in dir.get_files():
			var img = Image.load_from_file("res://woman_pck/"+file)
			var texture = ImageTexture.create_from_image(img)
			sframes.add_frame("default",texture,1.0,i)
			i+=1
		$Sprite3D.frames = sframes
		$Sprite3D.play()
	else:
		print("no, had problem")
	pass # Replace with function body.
	pass # Replace with function body.


func _on_unzipper_unzip_complete() -> void:
	var dir= DirAccess.open("user://woman/")
	var sframes = SpriteFrames.new()
	var i=0
	for file in dir.get_files():
		if file.contains("import"):
			continue
		var img = Image.load_from_file("user://woman/"+file)
		var texture = ImageTexture.create_from_image(img)
		sframes.add_frame("default",texture,1.0,i)
		i+=1
	$Sprite3D.frames = sframes
	$Sprite3D.play()
	pass # Replace with function body.
