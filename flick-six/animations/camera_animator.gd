extends Node

var camera: Camera3D
var base_pos: Vector3
var base_quat: Quaternion
var target_pos: Vector3
var target_quat: Quaternion

func setup(cam: Camera3D) -> void:
	camera = cam
	base_pos = camera.global_position
	base_quat = camera.quaternion
	target_pos = base_pos
	target_quat = base_quat

func reset() -> void:
	target_pos = base_pos
	target_quat = base_quat

func trigger_shot_pan(shot_dir: Vector3) -> void:
	target_pos = Vector3(0.0, 2.65, 3.4)
	var look_target = target_pos + Vector3(shot_dir.x, shot_dir.y * 0.4, shot_dir.z) * 10.0
	var look_transform = camera.global_transform.looking_at(look_target, Vector3.UP)
	target_quat = look_transform.basis.get_rotation_quaternion()

func update_camera(delta: float) -> void:
	if camera:
		camera.global_position = camera.global_position.lerp(target_pos, delta * 5.0)
		camera.quaternion = camera.quaternion.slerp(target_quat, delta * 5.0)

