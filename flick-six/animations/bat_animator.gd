extends Node3D

var default_pos: Vector3 = Vector3(0.20, 0.78, -0.62)
var default_rot: Vector3 = Vector3(-0.25, -0.32, 0.12)

var blade: MeshInstance3D
var handle: MeshInstance3D

func _ready() -> void:
	build_mesh()
	reset_stance()

func build_mesh() -> void:
	var wood_mat = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.82, 0.68, 0.48, 1.0)
	
	var grip_mat = StandardMaterial3D.new()
	grip_mat.albedo_color = Color(0.9, 0.9, 0.9, 1.0)
	
	blade = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.11, 0.58, 0.04)
	blade.mesh = box
	blade.material_override = wood_mat
	blade.position = Vector3(0, -0.29, 0)
	add_child(blade)
	
	handle = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.018
	cyl.bottom_radius = 0.018
	cyl.height = 0.28
	handle.mesh = cyl
	handle.material_override = grip_mat
	handle.position = Vector3(0, 0.14, 0)
	add_child(handle)

func reset_stance() -> void:
	position = default_pos
	rotation = default_rot

func play_swing(swipe_dir: Vector2) -> void:
	var tween = create_tween()
	var sweep_x = swipe_dir.x * 0.35
	var sweep_y = -swipe_dir.y * 0.15
	var target_pos = default_pos + Vector3(sweep_x, sweep_y + 0.12, -0.40)
	
	var rot_y = -swipe_dir.x * 1.8
	var rot_x = -0.9 + (swipe_dir.y * 0.4)
	var rot_z = -0.5
	var target_rot = Vector3(rot_x, rot_y, rot_z)
	
	tween.set_parallel(true)
	tween.tween_property(self, "rotation", target_rot, 0.13).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_pos, 0.13).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.chain().tween_interval(0.12)
	tween.tween_property(self, "rotation", default_rot, 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "position", default_pos, 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

