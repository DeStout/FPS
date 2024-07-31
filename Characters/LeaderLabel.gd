extends Control


var team : Color
var score := 0


func set_up(new_team : Color) -> void:
	team = new_team
	$HLayout/TeamColor/Color.color = new_team


func set_score(new_score) -> void:
	score = new_score
	$HLayout/Score/Label.text = str(score)
