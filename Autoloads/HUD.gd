extends CanvasLayer


func _ready() -> void:
	set_process(false)
	visible = false


func _process(delta: float) -> void:
	#_fade_health(delta)
	_fade_dmg(delta)


func setup_single_player() -> void:
	$MatchTimer.visible = false
	$UI.visible = true
	$FadeInOut.visible = true


func exit_game() -> void:
	visible = false


func fade_in() -> void:
	visible = true
	$FadeInOut.color.a = 1
	var open_time = 1.0
	var tween = create_tween()
	tween.tween_property($FadeInOut, "color:a", 0.0, open_time)
	await tween.finished
	set_process(true)
	return


func fade_out() -> void:
	$FadeInOut.visible = true
	$FadeInOut.color.a = 0
	var close_time = 1.75
	var tween = create_tween()
	tween.tween_property($FadeInOut, "color:a", 1.0, close_time)
	await tween.finished
	return


func update_weapon(ammo_in_mag, mag_size, extra_ammo) -> void:
	%AmmoInMag.text = str(ammo_in_mag) + " / " + str(mag_size)
	%ExtraAmmo.text = str(extra_ammo)


func update_health(max_health, max_armor, health, armor) -> void:
	%HealthMod.color.a = 1
	
	# Health Boxes
	var box_count := %HealthMod/HealthBar.get_child_count()
	var health_per_box : int = max_health / box_count
	var filled_boxes : int = health / health_per_box
	for box_num in range(0, box_count):
		var box : ColorRect = %HealthMod/HealthBar.get_child(box_count - box_num - 1)
		if box_num < filled_boxes:
			box.color.a = 1
		elif box_num == filled_boxes:
			box.color.a = fmod(health, health_per_box) / float(health_per_box)
		else:
			box.color.a = 0

	# Armor Boxes
	box_count = %HealthMod/ArmorBar.get_child_count()
	var armor_per_box : int = max_armor / box_count
	filled_boxes = armor / armor_per_box
	for box_num in range(0, box_count):
		var box : ColorRect = %HealthMod/ArmorBar.get_child(box_count - box_num - 1)
		if box_num < filled_boxes:
			box.color.a = 1
		elif box_num == filled_boxes:
			box.color.a = fmod(armor, armor_per_box) / float(armor_per_box)
		else:
			box.color.a = 0


func show_crosshairs(show) -> void:
	$UI/Crosshair.visible = show


func zoom_crosshairs(show) -> void:
	$UI/Scope.visible = show


func show_damage(dmg_dir) -> void:
	if dmg_dir.y > 0:
		%Damage/Up.modulate.a = dmg_dir.y
	else:
		%Damage/Down.modulate.a = abs(dmg_dir.y)
	if dmg_dir.x > 0:
		%Damage/Right.modulate.a = dmg_dir.x
	else:
		%Damage/Left.modulate.a = abs(dmg_dir.x)


func _fade_health(delta) -> void:
	if %HealthMod.color.a > 0:
		%HealthMod.color.a -= delta


func _fade_dmg(delta) -> void:
	if %Damage/Up.modulate.a > 0:
		%Damage/Up.modulate.a -= delta
	if %Damage/Left.modulate.a > 0:
		%Damage/Left.modulate.a -= delta
	if %Damage/Down.modulate.a > 0:
		%Damage/Down.modulate.a -= delta
	if %Damage/Right.modulate.a > 0:
		%Damage/Right.modulate.a -= delta
