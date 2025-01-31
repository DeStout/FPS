extends CanvasLayer


var address := ""
var progress := [0]
var map_return := Callable()
var map_load := Callable()

var loaded := false
var status : int
var fake_progress := 0
var time := 0.0


func _ready() -> void:
	set_process(false)


func load(load_path : String, new_map_return : Callable, new_map_load : Callable) -> void:
	ResourceLoader.load_threaded_request(load_path)
	status = ResourceLoader.load_threaded_get_status(load_path, progress)
	
	assert(status == ResourceLoader.THREAD_LOAD_IN_PROGRESS, "Map Loading Failed")
	visible = true
	address = load_path
	map_return = new_map_return
	map_load = new_map_load
	set_process(true)


func _process(delta: float) -> void:
	_update_load()
	_update_UI(delta)


func _update_load() -> void:
	if !loaded:
		status = ResourceLoader.load_threaded_get_status(address, progress)
		
	if fake_progress < int(progress[0]*100):
		fake_progress += min(randi_range(0, 2), int(progress[0]*100 - fake_progress))
	elif fake_progress == 100:
		$Percent.modulate = Color.BLUE
		$Continue.visible = true
		
	if status == ResourceLoader.THREAD_LOAD_LOADED and !loaded:
		map_return.call(ResourceLoader.load_threaded_get(address))
		loaded = true


func _update_UI(delta : float) -> void:
	$Percent.text = str(fake_progress) + " %"
	
	if fake_progress == 100:
		time += delta
		$Continue.modulate.a = (cos(time*2)+2)/3
		
		if Input.is_anything_pressed():
			map_load.call_deferred()
			queue_free()
