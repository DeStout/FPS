extends Control


var leader_label_ := preload("res://Characters/Multiplayer/LeaderLabel.tscn")

@export var list : VBoxContainer
var teams := []


func _set_up(new_leaders : Array):
	for team in new_leaders:
		var new_team : Control = leader_label_.instantiate()
		new_team.set_up(team)
		teams.append(new_team)


func update(new_leaders : Dictionary) -> void:
	if !teams.size():
		_set_up(new_leaders.keys())
	
	for team in teams:
		for leader in new_leaders:
			if team.team == leader:
				team.set_score(new_leaders[leader])
	_top_teams()


func _top_teams() -> void:
	var top_teams := []
	for i in range(min(teams.size(), 3)):
		top_teams.append(leader_label_.instantiate())
	
	for tt in range(top_teams.size()):
		for team in teams:
			if team.score > top_teams[tt].score and !top_teams.has(team):
				top_teams[tt] = team
	for i in range(top_teams.size()-1, -1, -1):
		if top_teams[i].score == 0:
			top_teams.erase(top_teams[i])
			
	for old_leader in list.get_children():
		list.remove_child(old_leader)
	for leader in top_teams:
		list.add_child(leader)
