extends Node3D


func swing_to_main_menu() -> void:
	$"../PlayMenu/Collision".disabled = true
	$"../OptionsMenu/Collision".disabled = true
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "position", Vector3(0, 4, 0), 0.5)
	tween.tween_property(self, "basis", Basis.looking_at(Vector3.FORWARD), 0.5)
	await tween.finished
	
	$"../MainMenu/Collision".disabled = false


func swing_to_play_menu() -> void:
	$"../MainMenu/Collision".disabled = true
	$"../SettingsMenu/Collision".disabled = true
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "basis", Basis.looking_at(Vector3.LEFT), 0.5)
	tween.tween_property(self, "position", Vector3(-5, 4, 0), 0.5)
	await tween.finished
	
	$"../PlayMenu/Collision".disabled = false


func swing_to_settings_menu() -> void:
	$"../MainMenu/Collision".disabled = true
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "basis", Basis.looking_at(Vector3.BACK), 0.5)
	tween.tween_property(self, "position", Vector3(0, 4, 0), 0.5)
	await tween.finished
	
	$"../SettingsMenu/Collision".disabled = false


func swing_to_options_menu() -> void:
	$"../MainMenu/Collision".disabled = true
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "basis", Basis.looking_at(Vector3.RIGHT), 0.5)
	tween.tween_property(self, "position", Vector3(5, 4, 0), 0.5)
	await tween.finished
	
	$"../OptionsMenu/Collision".disabled = false
