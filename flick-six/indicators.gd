extends CanvasLayer

signal loft_toggled(is_lofted: bool)
signal physics_changed(power: float, friction: float, pace: float, loft: float)

var toggle_btn: Button
var tweak_btn: Button
var tweak_panel: PanelContainer
var feedback_lbl: Label
var feedback_timer: float = 0.0

var power_lbl: Label
var friction_lbl: Label
var pace_lbl: Label
var loft_lbl: Label

var current_power: float = 48.0
var current_friction: float = 0.96
var current_pace: float = 0.60
var current_loft: float = 0.62
var is_lofted: bool = false

func _ready() -> void:
	build_ui()

func build_ui() -> void:
	toggle_btn = Button.new()
	toggle_btn.text = "[ GROUND ]"
	toggle_btn.position = Vector2(24, 1160)
	toggle_btn.size = Vector2(160, 56)
	toggle_btn.add_theme_font_size_override("font_size", 20)
	toggle_btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.2))
	toggle_btn.pressed.connect(_on_toggle_pressed)
	add_child(toggle_btn)
	
	tweak_btn = Button.new()
	tweak_btn.text = "[ TWEAK ]"
	tweak_btn.position = Vector2(536, 1160)
	tweak_btn.size = Vector2(160, 56)
	tweak_btn.add_theme_font_size_override("font_size", 20)
	tweak_btn.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	tweak_btn.pressed.connect(toggle_tweak_panel)
	add_child(tweak_btn)
	
	feedback_lbl = Label.new()
	feedback_lbl.text = ""
	feedback_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_lbl.position = Vector2(0, 260)
	feedback_lbl.size = Vector2(720, 60)
	feedback_lbl.add_theme_font_size_override("font_size", 36)
	add_child(feedback_lbl)
	
	build_tweak_panel()

func build_tweak_panel() -> void:
	tweak_panel = PanelContainer.new()
	tweak_panel.position = Vector2(360, 40)
	tweak_panel.size = Vector2(340, 300)
	add_child(tweak_panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	tweak_panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "PHYSICS TWEAKER [TAB]"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0))
	vbox.add_child(title)
	
	power_lbl = Label.new()
	power_lbl.text = "Hit Power: " + str(snapped(current_power, 0.1))
	vbox.add_child(power_lbl)
	var power_slider = HSlider.new()
	power_slider.min_value = 20.0
	power_slider.max_value = 85.0
	power_slider.step = 1.0
	power_slider.value = current_power
	power_slider.value_changed.connect(func(val):
		current_power = val
		power_lbl.text = "Hit Power: " + str(snapped(val, 0.1))
		emit_physics()
	)
	vbox.add_child(power_slider)
	
	friction_lbl = Label.new()
	friction_lbl.text = "Turf Roll (Friction): " + str(snapped(current_friction, 0.005))
	vbox.add_child(friction_lbl)
	var friction_slider = HSlider.new()
	friction_slider.min_value = 0.85
	friction_slider.max_value = 0.995
	friction_slider.step = 0.005
	friction_slider.value = current_friction
	friction_slider.value_changed.connect(func(val):
		current_friction = val
		friction_lbl.text = "Turf Roll (Friction): " + str(snapped(val, 0.005))
		emit_physics()
	)
	vbox.add_child(friction_slider)
	
	pace_lbl = Label.new()
	pace_lbl.text = "Bowler Flight Time: " + str(snapped(current_pace, 0.05)) + "s"
	vbox.add_child(pace_lbl)
	var pace_slider = HSlider.new()
	pace_slider.min_value = 0.35
	pace_slider.max_value = 1.10
	pace_slider.step = 0.05
	pace_slider.value = current_pace
	pace_slider.value_changed.connect(func(val):
		current_pace = val
		pace_lbl.text = "Bowler Flight Time: " + str(snapped(val, 0.05)) + "s"
		emit_physics()
	)
	vbox.add_child(pace_slider)
	
	loft_lbl = Label.new()
	loft_lbl.text = "Loft Angle Height: " + str(snapped(current_loft, 0.05))
	vbox.add_child(loft_lbl)
	var loft_slider = HSlider.new()
	loft_slider.min_value = 0.2
	loft_slider.max_value = 0.9
	loft_slider.step = 0.05
	loft_slider.value = current_loft
	loft_slider.value_changed.connect(func(val):
		current_loft = val
		loft_lbl.text = "Loft Angle Height: " + str(snapped(val, 0.05))
		emit_physics()
	)
	vbox.add_child(loft_slider)

func emit_physics() -> void:
	physics_changed.emit(current_power, current_friction, current_pace, current_loft)

func toggle_tweak_panel() -> void:
	tweak_panel.visible = not tweak_panel.visible

func _on_toggle_pressed() -> void:
	is_lofted = not is_lofted
	if is_lofted:
		toggle_btn.text = "[ LOFT ]"
		toggle_btn.add_theme_color_override("font_color", Color(1.0, 0.32, 0.15))
	else:
		toggle_btn.text = "[ GROUND ]"
		toggle_btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.2))
	loft_toggled.emit(is_lofted)

func show_feedback(txt: String, col: Color) -> void:
	feedback_lbl.text = txt
	feedback_lbl.add_theme_color_override("font_color", col)
	feedback_timer = 1.4

func _process(delta: float) -> void:
	if feedback_timer > 0.0:
		feedback_timer -= delta
		if feedback_timer <= 0.0:
			feedback_lbl.text = ""

