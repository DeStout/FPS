extends Control


signal accept_button

var setting_defaults : Dictionary = {
	"game_mode" : 0,
	"level" : 2,
	"num_ai" : 4
}


func accept_pressed() -> void:
	play_select()
	
	var game_settings : GameSettings = GameSettings.new()
	game_settings.game_mode = $GameMode/ModeMenu.selected
	game_settings.level = $LevelSelect/LevelMenu.selected
	game_settings.num_ai = $NumAI/AIMenu.selected
	Globals.set_game_settings(game_settings)
	
	accept_button.emit()


func defaults_pressed() -> void:
	$GameMode/ModeMenu.selected = setting_defaults["game_mode"]
	$LevelSelect/LevelMenu.selected = setting_defaults["level"]
	$NumAI/AIMenu.selected = setting_defaults["num_ai"]
	play_select()


func play_select(_item = 0) -> void:
	$Select.play()


func play_boop(_item = 0) -> void:
	$Boop.play()
