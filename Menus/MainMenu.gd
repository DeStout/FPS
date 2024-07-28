extends Control


func _ready() -> void:
	$PlayMenu.visible = false
	$OptionsMenu.visible = false


func update() -> void:
	$OptionsMenu.update()


func play_button() -> void:
	play_select()
	$OptionsMenu.visible = false
	$PlayMenu.visible = !$PlayMenu.visible


func options_button() -> void:
	play_select()
	$PlayMenu.visible = false
	$OptionsMenu.visible = !$OptionsMenu.visible


func quit_button() -> void:
	play_select()
	await $Select.play
	get_tree().quit()


func play_boop(t := 0) -> void:
	$Boop.play()


func play_select(t := 0) -> void:
	$Select.play()
