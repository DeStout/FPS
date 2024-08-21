extends CanvasLayer


var address := ""
var progress := [0]
var map_return := Callable()
var map_load := Callable()

var status : int
var fake_progress := 0
var time := 0.0


func _ready() -> void:
	set_process(false)


func load(load_path : String, new_map_return : Callable, new_map_load : Callable) -> void:
	ResourceLoader.load_threaded_request(load_path)
	status = ResourceLoader.load_threaded_get_status(load_path, progress)
	
	if status != 1:
		get_tree().quit()
	visible = true
	address = load_path
	map_return = new_map_return
	map_load = new_map_load
	set_process(true)


func _process(delta: float) -> void:
	_update_UI(delta)
	_update_load()


func _update_UI(delta : float) -> void:
	$Percent.text = str(fake_progress) + " %"
	
	if fake_progress == 100:
		time += delta
		$Continue.modulate.a = (cos(time*2)+2)/3
		
		if Input.is_anything_pressed():
			_load_complete()


func _update_load() -> void:
	status = ResourceLoader.load_threaded_get_status(address, progress)
	if fake_progress < int(progress[0]*100):
		fake_progress += min(randi_range(0, 2), int(progress[0]*100 - fake_progress))
		
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		$Percent.modulate = Color.BLUE
		$Continue.visible = true
		map_return.call_deferred(ResourceLoader.load_threaded_get(address))


func _load_complete() -> void:
	visible = false
	fake_progress = 0
	$Continue.visible = false
	$Continue.modulate.a = 1
	$Percent.modulate = Color.RED
	address = ""
	map_return = Callable()
	set_process(false)
	map_load.call_deferred()
	map_load = Callable()
	
