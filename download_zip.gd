@tool
extends EditorScript

func _run():
    print("running")
    var url = "https://arizona.app.box.com/shared/static/jnw77jvgtkaux38go9ebt16qvwmsgqzf"
    
    var client = HTTPClient.new()
    #client.request_completed.connect(self._client_completed)
    var err = client.request(HTTPClient.METHOD_GET,url,[])
    if err != OK:
        print("problem",err)
        return
    print("continue",err)
    # make request 
    
    client.poll()
   
    print("delayed")
     # Keep polling until response arrives
    while client.get_status() == HTTPClient.STATUS_REQUESTING:
        err = client.poll()
        print("poll said",err)
        #await Engine.get_main_loop().process_frame
        OS.delay_msec(1000)
    print("done requesting, now checking response",client.has_response())
    # Accumulate chunks if data response is valid
    
    if client.has_response():
        var rb = PackedByteArray()
        while client.get_status() == HTTPClient.STATUS_BODY:
            err = client.poll()
            print("poll said, ",err)
            var chunk = client.read_response_body_chunk()
            if chunk.size() == 0:
                #await Engine.get_main_loop().process_frame
                OS.delay_msec(1000)
            else:
                rb.append_array(chunk)
        
        print("Data: ", rb.get_string_from_utf8())
        var file: FileAccess = FileAccess.open("test.zip", FileAccess.WRITE)
        file.store_buffer(rb)     
        print("done")
# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
    #var json = JSON.new()
    #json.parse(body.get_string_from_utf8())
    #var response = json.get_data()

    # Will print the user agent string used by the HTTPRequest node (as recognized by httpbin.org).
    #print(response.headers["User-Agent"])
    var file: FileAccess = FileAccess.open("test.zip", FileAccess.WRITE)
    file.store_buffer(body)
    print("saved")
