extends BulletWeapon


func can_fire() -> bool:
	return ammo_in_mag > 0 and $FireTimer.is_stopped()


func reload() -> void:
	is_reloading = true


func load_shell() -> void:
	ammo_in_mag += 1
	
	if ammo_in_mag == properties.mag_size:
		is_reloading = false