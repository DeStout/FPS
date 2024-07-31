extends Label


func _ready() -> void:
	if Globals.match_settings.time != 0:
		visible = true


func set_time(match_time : int) -> void:
	var minutes = match_time / 60
	var seconds = match_time % 60
	text = str(minutes) + " : " + "%0*d" % [2, seconds]
