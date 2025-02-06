extends Node3D


signal release(release_point)

func release_grenade() -> void:
	release.emit($ReleasePoint.global_position)
