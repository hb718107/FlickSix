extends Node3D

@export var flight_time: float = 0.60
@export var gravity: float = 18.0
@export var target_crease_height: float = 0.65

var hit_power: float = 48.0
var grass_friction: float = 0.96
var loft_arc: float = 0.62

var release_pos: Vector3 = Vector3(0.0, 2.0, -20.12)
var bounce_pos: Vector3 = Vector3(0.1, 0.13, -6.0)

var ball: MeshInstance3D
var marker: MeshInstance3D

var ball_vel: Vector3 = Vector3.ZERO
var is_active: bool = false
var has_bounced: bool = false
var is_hit: bool = false
var is_lofted: bool = false
var boundary_scored: bool = false

@onready var camera: Camera3D = $StrikerCamera
@onready var stumps_striker: CSGBox3D = $StumpsStriker
var default_stumps_pos: Vector3
var default_stumps_rot: Vector3

var cam_anim: Node
var bat_anim: Node3D
var indicators: CanvasLayer

var swipe_start: Vector2 = Vector2.ZERO
var is_swiping: bool = false

func _ready() -> void:
	default_stumps_pos = stumps_striker.position
	default_stumps_rot = stumps_striker.rotation
	
	setup_subsystems()
	create_marker()
	create_ball()
	launch_ball()

func setup_subsystems() -> void:
	var cam_script = load("res://animations/camera_animator.gd")
	cam_anim = cam_script.new()
	cam_anim.setup(camera)
	add_child(cam_anim)
	
	var bat_script = load("res://animations/bat_animator.gd")
	bat_anim = bat_script.new()
	add_child(bat_anim)
	
	var ind_script = load("res://indicators.gd")
	indicators = ind_script.new()
	indicators.loft_toggled.connect(func(lofted): is_lofted = lofted)
	indicators.physics_changed.connect(func(power, friction, pace, loft):
		hit_power = power
		grass_friction = friction
		flight_time = pace
		loft_arc = loft
	)
	add_child(indicators)

func create_marker() -> void:
	marker = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.35
	cyl.bottom_radius = 0.35
	cyl.height = 0.02
	marker.mesh = cyl
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.15, 0.15, 1.0)
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	marker.material_override = mat
	
	add_child(marker)
	marker.global_position = bounce_pos

func create_ball() -> void:
	ball = MeshInstance3D.new()
	var sph = SphereMesh.new()
	sph.radius = 0.09
	sph.height = 0.18
	ball.mesh = sph
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.1, 0.1, 1.0)
	ball.material_override = mat
	
	add_child(ball)

func launch_ball() -> void:
	ball.global_position = release_pos
	has_bounced = false
	is_hit = false
	boundary_scored = false
	
	stumps_striker.position = default_stumps_pos
	stumps_striker.rotation = default_stumps_rot
	
	if cam_anim:
		cam_anim.reset()
	if bat_anim:
		bat_anim.reset_stance()
	
	var vx = (bounce_pos.x - release_pos.x) / flight_time
	var vz = (bounce_pos.z - release_pos.z) / flight_time
	var vy = ((bounce_pos.y - release_pos.y) + (0.5 * gravity * flight_time * flight_time)) / flight_time
	
	ball_vel = Vector3(vx, vy, vz)
	is_active = true

func _process(delta: float) -> void:
	if cam_anim:
		cam_anim.update_camera(delta)

func _physics_process(delta: float) -> void:
	if not is_active:
		return
	
	ball_vel.y -= gravity * delta
	ball.global_position += ball_vel * delta
	
	if not is_hit:
		if not has_bounced and ball.global_position.z >= bounce_pos.z:
			has_bounced = true
			ball.global_position.y = bounce_pos.y + 0.09
			var vz = ball_vel.z * 0.88
			var vx = ball_vel.x
			var time_to_crease = max(0.05, (0.0 - ball.global_position.z) / vz)
			var vy = ((target_crease_height - ball.global_position.y) + (0.5 * gravity * time_to_crease * time_to_crease)) / time_to_crease
			ball_vel = Vector3(vx, vy, vz)
		
		if ball.global_position.z >= 0.0:
			var in_wicket_line = abs(ball.global_position.x) <= 0.16 and ball.global_position.y <= 0.82
			if in_wicket_line:
				trigger_bowled()
			elif ball.global_position.z >= 0.5:
				is_active = false
				indicators.show_feedback("DOT BALL", Color(0.7, 0.7, 0.7))
	else:
		if ball.global_position.y <= 0.1:
			ball.global_position.y = 0.1
			ball_vel.y = -ball_vel.y * 0.35
			ball_vel.x *= grass_friction
			ball_vel.z *= grass_friction
			if ball_vel.length() < 0.6:
				is_active = false
		
		var dist = Vector2(ball.global_position.x, ball.global_position.z).length()
		if dist >= 40.0 and not boundary_scored:
			boundary_scored = true
			if is_lofted:
				indicators.show_feedback("SIX!", Color(1.0, 0.85, 0.1))
			else:
				indicators.show_feedback("FOUR!", Color(0.2, 0.9, 1.0))
		
		if ball.global_position.length() > 65.0:
			is_active = false

func trigger_bowled() -> void:
	is_active = false
	indicators.show_feedback("BOWLED!", Color(1.0, 0.15, 0.15))
	
	var speed_factor = clamp(ball_vel.length() / 20.0, 0.8, 2.5)
	var fall_duration = clamp(0.28 / speed_factor, 0.12, 0.35)
	var fall_dist = 0.55 * speed_factor
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(stumps_striker, "rotation", Vector3(1.45, 0.15, 0.2), fall_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(stumps_striker, "position", default_stumps_pos + Vector3(0.04, -0.32, fall_dist), fall_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	ball_vel = Vector3(ball_vel.x * 0.25, 2.2, ball_vel.z * 0.2)

func trigger_snick(inside_edge: bool) -> void:
	is_hit = true
	var snick_x = 0.25 if inside_edge else (0.55 if randf() > 0.5 else -0.55)
	var snick_dir = Vector3(snick_x, 0.22, 0.88).normalized()
	ball_vel = snick_dir * (hit_power * 0.45)
	indicators.show_feedback("SNICK (EDGE)!", Color(1.0, 0.2, 0.2))
	cam_anim.trigger_shot_pan(snick_dir)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		launch_ball()
		return
	
	if event.is_action_pressed("ui_focus_next"):
		indicators.toggle_tweak_panel()
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				swipe_start = event.position
				is_swiping = true
			elif is_swiping:
				is_swiping = false
				var swipe_vec = event.position - swipe_start
				if swipe_vec.length() > 16.0:
					process_flick(swipe_vec)
	
	elif event is InputEventMouseMotion and is_swiping:
		var current_vec = event.position - swipe_start
		if current_vec.length() > 28.0 and ball.global_position.z >= -2.2:
			is_swiping = false
			process_flick(current_vec)

func process_flick(swipe_vec: Vector2) -> void:
	if not is_active or is_hit:
		return
	
	var dir_2d = swipe_vec.normalized()
	bat_anim.play_swing(dir_2d)
	
	var bz = ball.global_position.z
	if bz < -2.2:
		indicators.show_feedback("TOO EARLY!", Color(1.0, 0.4, 0.2))
		return
	elif bz > 0.45:
		indicators.show_feedback("TOO LATE!", Color(0.9, 0.3, 0.3))
		return
	
	var dz = bz - (-0.6)
	if abs(dz) <= 0.35:
		execute_hit(dir_2d, hit_power, "PERFECT!", Color(0.2, 1.0, 0.4), false)
	elif dz < -0.35 and dz >= -0.85:
		execute_hit(dir_2d, hit_power * 0.82, "GOOD", Color(0.4, 0.85, 1.0), false)
	elif dz < -0.85:
		execute_hit(dir_2d, hit_power * 0.55, "EARLY", Color(1.0, 0.6, 0.2), true)
	elif dz > 0.35:
		var in_wicket_line = abs(ball.global_position.x) <= 0.16 and ball.global_position.y <= 0.82
		if in_wicket_line:
			if randf() <= 0.40:
				trigger_bowled()
			else:
				trigger_snick(true)
		else:
			if randf() <= 0.60:
				trigger_snick(false)
			else:
				indicators.show_feedback("PLAY & MISS", Color(0.85, 0.3, 0.3))

func execute_hit(dir_2d: Vector2, speed: float, rating: String, col: Color, force_lofted: bool) -> void:
	is_hit = true
	indicators.show_feedback(rating, col)
	
	var shot_x = dir_2d.x * 1.3
	var shot_z = dir_2d.y * 1.3
	var shot_y: float = 0.08
	
	if is_lofted or force_lofted:
		shot_y = loft_arc
	
	var shot_dir = Vector3(shot_x, shot_y, shot_z).normalized()
	ball_vel = shot_dir * speed
	cam_anim.trigger_shot_pan(shot_dir)
