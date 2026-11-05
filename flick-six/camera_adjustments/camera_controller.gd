extends Node

enum CameraMode { BROADCAST, OVER_SHOULDER, FPS }

var camera: Camera3D
var current_mode: CameraMode = CameraMode.BROADCAST

var base_pos: Vector3
var base_quat: Quaternion
var target_pos: Vector3
var target_quat: Quaternion

func setup(cam: Camera3D) -> void:
	camera = cam
	apply_mode(current_mode)
	camera.global_position = base_pos
	camera.quaternion = base_quat

func apply_mode(mode: CameraMode) -> void:
	current_mode = mode
	var look_target: Vector3
	
	match current_mode:
		CameraMode.BROADCAST:
			base_pos = Vector3(0.0, 2.1, 3.4)
			look_target = Vector3(0.0, 0.8, -10.0)
		CameraMode.OVER_SHOULDER:
			base_pos = Vector3(0.55, 1.85, 2.4)
			look_target = Vector3(0.0, 0.7, -10.0)
		CameraMode.FPS:
			base_pos = Vector3(0.20, 1.48, -0.22)
			look_target = Vector3(0.04, 0.52, -8.0)
	
	target_pos = base_pos
	if camera:
		var temp_xform = Transform3D().looking_at(look_target - base_pos, Vector3.UP)
		base_quat = temp_xform.basis.get_rotation_quaternion()
		target_quat = base_quat

func cycle_mode() -> String:
	var next_mode = (int(current_mode) + 1) % 3
	apply_mode(next_mode as CameraMode)
	return get_mode_name()

func get_mode_name() -> String:
	match current_mode:
		CameraMode.BROADCAST:
			return "BROADCAST"
		CameraMode.OVER_SHOULDER:
			return "SHOULDER"
		CameraMode.FPS:
			return "FPS"
	return "UNKNOWN"

func reset() -> void:
	target_pos = base_pos
	target_quat = base_quat

func trigger_shot_pan(shot_dir: Vector3) -> void:
	var pan_pos: Vector3
	var look_target: Vector3
	
	match current_mode:
		CameraMode.BROADCAST:
			pan_pos = Vector3(0.0, 2.65, 3.4)
			look_target = pan_pos + Vector3(shot_dir.x, shot_dir.y * 0.4, shot_dir.z) * 10.0
		CameraMode.OVER_SHOULDER:
			pan_pos = Vector3(0.55, 2.3, 2.4)
			look_target = pan_pos + Vector3(shot_dir.x, shot_dir.y * 0.4, shot_dir.z) * 10.0
		CameraMode.FPS:
			pan_pos = base_pos
			look_target = pan_pos + Vector3(shot_dir.x, shot_dir.y * 0.4, shot_dir.z) * 10.0
	
	target_pos = pan_pos
	var look_transform = camera.global_transform.looking_at(look_target, Vector3.UP)
	target_quat = look_transform.basis.get_rotation_quaternion()

func update_camera(delta: float) -> void:
	if camera:
		camera.global_position = camera.global_position.lerp(target_pos, delta * 5.0)
		camera.quaternion = camera.quaternion.slerp(target_quat, delta * 5.0)

