extends BulletWeapon


func can_fire() -> bool:
	return ammo_in_mag > 0 and fire_time == 0.0


func fire() -> void:
	super()
	is_reloading = false


func reload() -> void:
	is_reloading = true


func load_shell() -> void:
	ammo_in_mag += 1
	extra_ammo -= 1
