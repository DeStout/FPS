extends Control


func _ready() -> void:
	$BotSimMenu.visible = false
	$OptionsMenu.visible = false
	$OptionsMenu.default()


func update() -> void:
	$OptionsMenu.update()


func single_player_button() -> void:
	play_select()
	$BotSimMenu.visible = false
	$OptionsMenu.visible = false
	$SinglePlayerMenu.visible = !$SinglePlayerMenu.visible


func bot_sim_button() -> void:
	play_select()
	$SinglePlayerMenu.visible = false
	$OptionsMenu.visible = false
	$BotSimMenu.visible = !$BotSimMenu.visible


func options_button() -> void:
	play_select()
	$SinglePlayerMenu.visible = false
	$BotSimMenu.visible = false
	$OptionsMenu.visible = !$OptionsMenu.visible


func quit_button() -> void:
	play_select()
	await $Select.play
	get_tree().quit()


func play_boop(_t := 0) -> void:
	$Boop.play()


func play_select(_t := 0) -> void:
	$Select.play()
