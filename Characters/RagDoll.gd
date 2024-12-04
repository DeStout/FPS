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
	

func match_pose_transform(manny_skel, manny_trans, body_seg_shot) -> void:
	transform = manny_trans
	for bone in get_bone_count():
		set_bone_pose(bone, manny_skel.get_bone_pose(bone))
		
		if find_bone($PhysBoneSim.get_node(body_seg_shot).bone_name) == bone:
			$PhysBoneSim.get_node(body_seg_shot).joint_type = PhysicalBone3D.JOINT_TYPE_NONE
	
	await get_tree().create_timer(.01).timeout
	$PhysBoneSim.physical_bones_start_simulation()
	
	$FadeoutTimer.start(vis_time)
	return


func add_impulse(shooter_pos : Vector3, body_seg_shot : String, 
													gun_impulse : float) -> void:
	var body_seg : PhysicalBone3D = $PhysBoneSim.get_node(body_seg_shot)
	var impulse = shooter_pos.direction_to(global_position) * gun_impulse
	body_seg.apply_central_impulse(impulse)


func set_fadeout() -> void:
	surf_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	joint_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fadeout = true
