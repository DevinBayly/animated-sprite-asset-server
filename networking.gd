extends Node
signal projectNames
# By default, these expressions are interchangeable.
var PORT = 8081
#var IP_ADDRESS = "godotcommunicator.TRA220030.projects.jetstream-cloud.org"
#var IP_ADDRESS ="149.165.150.98"
#var IP_ADDRESS="localhost"
var IP_ADDRESS="172.17.101.166"
#var IP_ADDRESS = "192.168.0.151"
var MAX_CLIENTS = 2
var peer
var num_peers = 0
@onready var http_requester = $HTTPRequest
func _ready() -> void:
	if OS.has_feature("linux"):
		var arg = OS.get_cmdline_user_args()[0] # try to see if we started up with the word "server"
		print(OS.get_cmdline_user_args())
		if arg == "server":
			print("I am a server")
			# Create server.
			peer = ENetMultiplayerPeer.new()
			peer.create_server(PORT, MAX_CLIENTS)
			multiplayer.multiplayer_peer = peer
			multiplayer.peer_connected.connect(server_handle_peer_connect)
			return		

	print("I am a client")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(client_connected_to_server)
	multiplayer.connection_failed.connect(con_failed)
	multiplayer.server_disconnected.connect(server_lost)
	multiplayer.peer_connected.connect(client_handle_peer_connect)
	
func client_handle_peer_connect(id):
	num_peers+=1
	
func server_lost():
	print("server lost")
func con_failed():
	print("failed to connect to server")
func client_connected_to_server():
	print("client made contact with server")
	# start a timeout that will then make an rpc call
	await get_tree().create_timer(2).timeout
	# signal up to the higher level that we are open to making communications
	
	
func server_handle_peer_connect(id):
	print("server was contacted by peer id",id)



var responses_csv_link = "https://docs.google.com/spreadsheets/d/e/2PACX-1vR8XG3cyWfHo2yXya28fyQCwO2b8hf-5zdqwH_Vkss9BmTwwri-qgflD2ZowyxYufrDLFN0EaMQxi22/pub?output=csv"
func make_form_request():
	http_requester.request_completed.connect(_on_request_completed)
	http_requester.request(responses_csv_link)

var projectGifsMap:Dictionary = {}
func _on_request_completed(result, response_code, headers, body):
	var contentType = headers[2]
	if contentType.find("image/gif") ==-1:
		var stringBody: String = body.get_string_from_utf8()
		if stringBody.find("The document has moved") !=-1:
			var redirectHTML = stringBody
			print("result is",redirectHTML)
			# pluck out the link for the redirect
			var startPattern = "A HREF=\""
			var startInt = redirectHTML.find(startPattern) + startPattern.length()
			var endInt = redirectHTML.find("\">here")
			var subLen = endInt - startInt
			var redirLink = redirectHTML.substr(startInt,subLen)
			print("trying request on link ",redirLink)
			$HTTPRequest.request(redirLink)
		else:
			# siwtch the callback function 
			
			
			#print("after redir", stringBody)
			var lines = stringBody.split("\n")
			var i=0
			for line in lines:
				if i ==0:
					print("header",line)
				else:
					# we will parse the row, and get the link, perhaps we need to add a name field to the form so that the assets can be named
					var lineParts = line.split(",")
					# right now the third part is the link so use that
					# NOTE this might need to change since we added the name 
					var gifLinks = lineParts[2]
					var projectName = lineParts[3]
					# the links in theory should be separated by new lines
					projectGifsMap[projectName] = gifLinks.split("\n")
					
					
				i+=1
			receive_project_names.rpc(projectGifsMap.keys())

@rpc("any_peer","call_remote","reliable",0)
func receive_project_names(pnames):
	if multiplayer.is_server():
		print("I just sent the names",pnames)
	else:
		# now I'm back in the client side, and I need to emit a signal with these names so the interface can update to show the options
		print("client received transmitted project names ",pnames)
		projectNames.emit(pnames)


@rpc("any_peer","call_remote","reliable",0)
func issue_form_response_request():
	var sender_id = multiplayer.get_remote_sender_id()
	# ensure it's not our own id, and that we aren't server, well I suppose since we called remote it wont be
	if multiplayer.is_server():
		make_form_request()
	else:
		# store this as other player's id
		print("I'm a client, I probably emitted this form call")
		
@rpc("any_peer","call_remote","reliable",0)
func retrieve_gifs(project_name):
	var sender_id = multiplayer.get_remote_sender_id()
	# ensure it's not our own id, and that we aren't server, well I suppose since we called remote it wont be
	if multiplayer.is_server():
		make_gifs_request(project_name)
	else:
		# store this as other player's id
		print("I'm a client, I probably emitted this gifs call")
		
func make_gifs_request(pname):
	http_requester.request_completed.connect(_on_gif_retrieval)
	# get the giflinks using the project name
	var gifs = projectGifsMap[pname]
	# NOTE perhaps do some sort of checking to see if the gif has been downloaded and converted already
	for gifLink in gifs:
		print("making gif request",gifLink)
		print("doign a test version, UNCOMMENT LINE BELOW FOR REAL GIF RETRIEVAL")
		#http_requester.request(gifLink)
		offline_test_version()
	
var folders_to_pack=[]
func _on_gif_retrieval(result, response_code, headers, body):
	# save the file to disk
	# could try parsing the header to get the name of the gif
	print("request has completed",headers)
	var file: FileAccess = FileAccess.open("test.gif", FileAccess.WRITE)
	file.store_buffer(body)
	# then we need to do various things like converting the gif into png frames
	# leaving this out for now since we are on a non linux ffmpeg machine
	var output = []
	OS.execute("mkdir",["-p","test"],output)
	print("mkdir output was ",output)
	output = []
	OS.execute("ffmpeg",["-i","test.gif","test/frame%04d.png"],output)
	print("output was ",output)
	folders_to_pack.push_back("test")
	# NOTE in the future we won't be able to get away with automatically running the packing and animation stuff here
	pack_up()
func offline_test_version():
	# save the file to disk
	# could try parsing the header to get the name of the gif
	
	# then we need to do various things like converting the gif into png frames
	# leaving this out for now since we are on a non linux ffmpeg machine
	var output = []
	OS.execute("mkdir",["-p","test"],output)
	print("mkdir output was ",output)
	output = []
	OS.execute("ffmpeg",["-i","test.gif","test/frame%04d.png"],output)
	print("output was ",output)
	folders_to_pack.push_back("test")
	# NOTE in the future we won't be able to get away with automatically running the packing and animation stuff here
	pack_up()
#### This code is what will do the conversion of pngs into animated tres, and eventually a whole pck file,
## will be triggered by the client clicking on a particular project name	

func pack_up() -> void:
	#
	var packfile = PCKPacker.new()
	packfile.pck_start("all_anims_test.pck")
	# need some way to tell what folders that were created should get added to pack
	for folder in folders_to_pack:
		var pathPrefix = "res://"+folder
		print("making animated resource")
		# currently not set up for multiple collections of pngs, perhaps this function would basically get called on each of folder of output images
		# assumption here is that the pngs have already been created
		var sframes = SpriteFrames.new()
		
		# then we need to make a SpriteFrames resource
		# make an animation on it
		sframes.add_animation("gifanimation")
		# then load each image as a texture and add it via add_frame method, increasing the at position argument
		# NOTE that the order of files isn't guaranteed
		var dirElements = ResourceLoader.list_directory(pathPrefix)
		var i =0
		for ele in dirElements:
			print("adding frame",ele)
			var texture = load(pathPrefix+"/"+ele)
			sframes.add_frame("gifanimation",texture,1.0,i)
			i+=1
			packfile.add_file(pathPrefix+"/"+ele,pathPrefix+"/"+ele)
		# lastly try to save the resource out 
		var result = ResourceSaver.save(sframes,"res://animatedFrames_test.tres")
		
		if result != OK:
			print("had a problem saving", result)
		packfile.add_file("res://animatedFrames_test.tres","res://animatedFrames.tres")
		packfile.flush()
