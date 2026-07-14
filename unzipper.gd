extends Node
@onready var http_request = $HTTPRequest

signal pck_made
signal unzip_complete

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dir = DirAccess.open("res://")
	if dir.file_exists("res://test.zip"):
		unpack_zip()
		#make_pck()
	else:
		var url = "https://arizona.app.box.com/shared/static/jnw77jvgtkaux38go9ebt16qvwmsgqzf"
		http_request.request_completed.connect(self._http_request_completed)

		# Perform a GET request. The URL below returns JSON as of writing.
		var error = http_request.request(url)
		if error != OK:
			push_error("An error occurred in the HTTP request.",error)

func make_pck():
	var pck_name ="user://all_anims_test.pck"
	var packfile = PCKPacker.new()
	packfile.pck_start(pck_name)
	var dirElements = ResourceLoader.list_directory("user://woman")
	var i=0
	var dir = DirAccess.open("res://")
	
	var root_dir = DirAccess.open("user://")
	for ele in dirElements:
		if "import" in ele:
			continue
		else:
			print(root_dir.get_current_dir().path_join("woman/")+ele)
			var im = Image.load_from_file(root_dir.get_current_dir().path_join("woman/")+ele)
			packfile.add_file("res://woman_pck/"+ele,"user://woman/"+ele)
	
	packfile.flush(true)
	
func unpack_zip():
	var reader = ZIPReader.new()
	reader.open("res://test.zip")


	var root_dir = DirAccess.open("user://")

	var files = reader.get_files()
	for file_path in files:
		# If the current entry is a directory.
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue

		# Write file contents, creating folders automatically when needed.
		# Not all ZIP archives are strictly ordered, so we need to do this in case
		# the file entry comes before the folder entry.
		print("making dir",root_dir.get_current_dir().path_join(file_path).get_base_dir())
		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var outfile = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		outfile.store_buffer(buffer)
		outfile.close()
		print("closed files",root_dir.get_current_dir().path_join(file_path))
	unzip_complete.emit()
# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	print("request complete",result,response_code,headers)
	var file: FileAccess = FileAccess.open("test.zip", FileAccess.WRITE)
	file.store_buffer(body)
	unpack_zip()
	#make_pck()
	pass # Replace with function body.
