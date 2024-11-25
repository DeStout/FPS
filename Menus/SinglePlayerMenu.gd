extends Control


@export var main_menu : Control = null
@onready var map_select := $Layout/Settings/Settings/Tabs/Game/Margin/VLayout/ \
													Level/VLayout/ModeOptions


func start_button() -> void:
	main_menu.play_select()
	main_menu.game.load_single_player(map_select.selected)


func back_button() -> void:
	main_menu.play_select()
	visible = false
