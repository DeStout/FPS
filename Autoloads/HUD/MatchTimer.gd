extends Label


func set_time(match_time : int) -> void:
	var minutes = match_time / 60
	var seconds = match_time % 60
	text = str(minutes) + " : " + "%0*d" % [2, seconds]
