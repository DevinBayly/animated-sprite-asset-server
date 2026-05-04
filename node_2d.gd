extends Node2D

var responses_csv_link = "https://docs.google.com/spreadsheets/d/e/2PACX-1vR8XG3cyWfHo2yXya28fyQCwO2b8hf-5zdqwH_Vkss9BmTwwri-qgflD2ZowyxYufrDLFN0EaMQxi22/pub?output=csv"
# redirection link 

func _on_response_grabber_pressed() -> void:
	$HTTPRequest.request_completed.connect(_on_request_completed)
	#$HTTPRequest.request("https://docs.google.com/spreadsheets/d/e/2PACX-1vR8XG3cyWfHo2yXya28fyQCwO2b8hf-5zdqwH_Vkss9BmTwwri-qgflD2ZowyxYufrDLFN0EaMQxi22/pub?gid=1297232721&single=true&output=csv")
	$HTTPRequest.request(responses_csv_link)
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
			#$HTTPRequest.request_completed.disconnect(_on_request_completed)
			$HTTPRequest.request_completed.connect(_on_gif_retrieval)
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
					var gifLink = lineParts[2]
					# NOTE perhaps do some sort of checking to see if the gif has been downloaded and converted already
					print("making gif request",gifLink)
					$HTTPRequest.request(gifLink)
					
				i+=1
		
	#for line in csv.split("\n"):
		#for link in line.split("\n"):
			#print(link)
			
	pass # Replace with function body.
func _on_gif_retrieval(result, response_code, headers, body):
	# save the file to disk
	# could try parsing the header to get the name of the gif
	print("request has completed",headers)
	var file: FileAccess = FileAccess.open("test.gif", FileAccess.WRITE)
	file.store_buffer(body)
	# then we need to do various things like converting the gif into png frames
	# leaving this out for now since we are on a non linux ffmpeg machine

	pass



func _on_button_pressed() -> void:
	print("making animated resource")
	# currently not set up for multiple collections of pngs, perhaps this function would basically get called on each of folder of output images
	# assumption here is that the pngs have already been created
	var sframes = SpriteFrames.new()
	
	# then we need to make a SpriteFrames resource
	# make an animation on it
	sframes.add_animation("gifanimation")
	# then load each image as a texture and add it via add_frame method, increasing the at position argument
	# NOTE that the order of files isn't guaranteed
	var dirElements = ResourceLoader.list_directory("res://frames")
	var i =0
	for ele in dirElements.slice(0,10):
		print("adding frame",ele)
		var texture = load("res://frames/"+ele)
		sframes.add_frame("gifanimation",texture,1.0,i)
		i+=1
	
	# lastly try to save the resource out 
	var result = ResourceSaver.save(sframes,"res://animatedFrames.tres")
	if result != OK:
		print("had a problem saving", result)
	pass # Replace with function body.
