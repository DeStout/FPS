extends Skeleton3D


signal exiting

var fadeout := false
@export var vis_time := 10.0
@export var fade_time := 0.5
@onready var surf_mat : BaseMaterial3D
@onready var joint_mat : BaseMaterial3D = $Joints.get_surface_override_material(0)


func _process(delta: float) -> void:
	if fadeout:
		surf_mat.albedo_color.a -= delta / fade_time
		joint_mat.albedo_color.a -= delta / fade_time
		if surf_mat.albedo_color.a <= 0:
			exiting.emit(self)
			queue_free()


func set_material(new_mat : BaseMaterial3D) -> void:
	$Surface.set_surface_override_material(0, new_mat)
	surf_mat = $Surface.get_surface_override_material(0)


func set_death_sfx(death_sfx : AudioStreamPlayer3D) -> void:
	$HeadBone.add_child(death_sfx)
	death_sfx.play()


func match_pose_transform(manny_skel, manny_trans) -> void:
	transform = manny_trans
	for bone in get_bone_count():
		set_bone_pose(bone, manny_skel.get_bone_pose(bone))
	
	await get_tree().create_timer(.001).timeout
	$PhysBoneSim.physical_bones_start_simulation()
	
	$FadeoutTimer.start(vis_time)
	return


func add_impulse(damage : Damage) -> void:
	var body_seg : PhysicalBone3D = $PhysBoneSim.get_node( \
									str(damage.body_seg_damaged.get_parent().name))
	var impulse = damage.global_position.direction_to(global_position) * damage.impulse
	body_seg.apply_central_impulse(impulse)


func set_fadeout() -> void:
	surf_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	joint_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fadeout = true
