extends Control


var address := ""
var progress := [0]
var return_callable := Callable()

var status : int
var fake_progress := 0
var time := 0.0


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	_update_UI(delta)
	_update_load()


func load(load_path : String, callback : Callable) -> void:
	ResourceLoader.load_threaded_request(load_path)
	status = ResourceLoader.load_threaded_get_status(load_path, progress)
	
	if status != 1:
		get_tree().quit()
	visible = true
	address = load_path
	return_callable = callback
	set_process(true)


func _update_UI(delta : float) -> void:
	$Percent.text = str(fake_progress) + " %"
	
	if fake_progress == 100:
		time += delta
		$Continue.modulate.a = (cos(time*2)+2)/3
		
		if Input.is_anything_pressed():
			_load_complete()


func _update_load() -> void:
	status = ResourceLoader.load_threaded_get_status(address, progress)
	fake_progress += min(randi_range(0, 2), \
									int(progress[0]*100 - fake_progress))
	if fake_progress < int(progress[0]*100):
		return
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		$Percent.modulate = Color.BLUE
		$Continue.visible = true


func _load_complete() -> void:
	return_callable.call_deferred(ResourceLoader.load_threaded_get(address))
	visible = false
	$Continue.visible = false
	$Continue.modulate.a = 1
	$Percent.modulate = Color.RED
	address = ""
	return_callable = Callable()
	set_process(false)
	
