extends RigidBody3D


@onready var skeleton := $Skeleton3D
var fadeout := false
@export var vis_time := 10.0
@export var fade_time := 0.5
@onready var surf_mat : BaseMaterial3D = \
								$Skeleton3D/Body.get_surface_override_material(0)


func _process(delta: float) -> void:
	if fadeout:
		surf_mat.albedo_color.a -= delta / fade_time
		if surf_mat.albedo_color.a <= 0:
			queue_free()


func set_color(new_color) -> void:
	$Skeleton3D/Body.get_surface_override_material(0).albedo_color = new_color
	

func match_pose_transform(puppet_skel, puppet_trans, body_seg_shot) -> void:
	transform = puppet_trans
	for bone in skeleton.get_bone_count():
		skeleton.set_bone_pose_position(bone, puppet_skel.get_bone_pose_position(bone))
		skeleton.set_bone_pose_rotation(bone, puppet_skel.get_bone_pose_rotation(bone))
		if bone == skeleton.find_bone(body_seg_shot):
			skeleton.set_bone_pose_scale(bone, Vector3(0.01, 0.01, 0.01))
		else:
			skeleton.set_bone_pose_scale(bone, puppet_skel.get_bone_pose_scale(bone))
	
	skeleton.physical_bones_start_simulation()
	var tween = create_tween()
	await tween.tween_interval(vis_time).finished
	surf_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fadeout = true


func add_impulse(shooter_pos : Vector3, body_seg_shot : String, 
													gun_impulse : float) -> void:
	var body_seg : PhysicalBone3D = skeleton.get_node(body_seg_shot)
	var impulse = shooter_pos.direction_to(global_position) * gun_impulse
	body_seg.apply_central_impulse(impulse)
