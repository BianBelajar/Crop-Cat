extends CanvasLayer

@onready var panel:        Panel  = $Panel
@onready var title_label:  Label  = $Panel/VBoxContainer/HBoxContainer/TitleLabel
@onready var icon_label:   Label  = $Panel/VBoxContainer/HBoxContainer/IconLabel
@onready var fact_label:   Label  = $Panel/FactLabel
@onready var close_button: Button = $Panel/CloseButton

const ANIM_DURATION: float = 0.35

func _ready() -> void:
	layer = 90
	panel.modulate = Color(1, 1, 1, 0)
	panel.scale    = Vector2(0.85, 0.85)

	# Judul
	if title_label:
		title_label.text = " Jurnal Quest"
		title_label.add_theme_font_size_override("font_size", 10)
	if icon_label:
		icon_label.text = "📜"
		icon_label.add_theme_font_size_override("font_size", 10)

	# FactLabel: font kecil, wrap, scroll jika teks panjang
	fact_label.add_theme_font_size_override("font_size", 9)
	fact_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	if not close_button.pressed.is_connected(_on_close_pressed):
		close_button.pressed.connect(_on_close_pressed)

func show_fact(teks: String) -> void:
	fact_label.text = teks.replace("\\n", "\n")
	_animate_in()

func tutup_jurnal() -> void:
	_animate_out()

func _animate_in() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), ANIM_DURATION)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), ANIM_DURATION) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_close_pressed() -> void:
	_animate_out()

func _animate_out() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 0), ANIM_DURATION * 0.7)
	tween.tween_property(panel, "scale", Vector2(0.85, 0.85), ANIM_DURATION * 0.7)
	get_tree().create_timer(ANIM_DURATION * 0.7 + 0.05).timeout.connect(queue_free)
