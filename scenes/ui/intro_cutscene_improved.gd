extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var subtitle_label: Label = $Panel/Label
@onready var continue_hint: Label = $ContinueHint

# =========================================================
# CONFIGURATION
# =========================================================
var TYPEWRITER_SPEED: float = 0.05  # Detik per huruf (0.05 = cepat, 0.1 = medium, 0.15 = lambat)
var FADE_DURATION: float = 0.8  # Durasi fade in/out
var SKIP_ON_CLICK: bool = true  # Bisa skip dengan click

# =========================================================
# CUTSCENE DATA
# =========================================================
var cutscene_data = [
	{
		"image": preload("res://assets/intro/jelajah.png"),
		"text": "Suatu hari, aku sedang berlayar menjelajahi lautan Nusantara yang indah..."
	},
	{
		"image": preload("res://assets/intro/badai.png"),
		"text": "Namun tiba-tiba, badai dahsyat datang mengamuk dan menghantam kapalku!"
	},
	{
		"image": preload("res://assets/intro/terdampar.png"),
		"text": "Kapalku hancur lebur... dan aku terdampar pingsan di pantai pulau yang tak kukenal."
	},
	{
		"image": preload("res://assets/intro/selamat.png"),
		"text": "Beruntung, seorang kakek kucing yang baik hati menemukanku dan membawaku ke rumahnya..."
	}
]

# =========================================================
# VARIABLE INTERNAL
# =========================================================
var current_slide: int = 0
var is_typing: bool = false
var is_transitioning: bool = false
var current_text: String = ""
var display_text: String = ""
var typewriter_timer: float = 0.0
var can_advance: bool = false

func _ready() -> void:
	print("⭐ Intro Cutscene Started!")
	
	# Setup awal
	texture_rect.modulate.a = 0.0  # Mulai transparan
	subtitle_label.text = ""
	continue_hint.text = "[Click untuk lanjut]"
	continue_hint.modulate.a = 0.0
	
	# Tampilkan slide pertama dengan fade in
	show_slide(current_slide)

func _process(delta: float) -> void:
	# Proses typewriter effect
	if is_typing:
		typewriter_timer += delta
		
		while typewriter_timer >= TYPEWRITER_SPEED and display_text.length() < current_text.length():
			display_text += current_text[display_text.length()]
			subtitle_label.text = display_text
			typewriter_timer = 0.0
		
		# Selesai typing
		if display_text.length() >= current_text.length():
			is_typing = false
			can_advance = true
			# Fade in continue hint
			var tween = create_tween()
			tween.tween_property(continue_hint, "modulate:a", 1.0, 0.5)

func _input(event: InputEvent) -> void:
	# Skip jika click atau tekan Enter/Spasi
	if SKIP_ON_CLICK and (event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)):
		get_tree().root.get_child(0).get_tree().set_input_as_handled()
		
		if is_typing:
			# Jika masih typing, skip langsung ke akhir
			skip_typewriter()
		elif can_advance:
			# Jika sudah selesai typing, lanjut ke slide berikutnya
			next_slide()

# =========================================================
# TYPEWRITER LOGIC
# =========================================================

func skip_typewriter() -> void:
	"""Skip typewriter effect dan tampilkan teks lengkap"""
	if is_typing:
		display_text = current_text
		subtitle_label.text = display_text
		is_typing = false
		can_advance = true
		typewriter_timer = 0.0
		
		# Fade in continue hint
		var tween = create_tween()
		tween.tween_property(continue_hint, "modulate:a", 1.0, 0.5)

func start_typewriter(text: String) -> void:
	"""Mulai typewriter effect"""
	current_text = text
	display_text = ""
	is_typing = true
	can_advance = false
	typewriter_timer = 0.0
	subtitle_label.text = ""
	continue_hint.modulate.a = 0.0

# =========================================================
# SLIDE MANAGEMENT
# =========================================================

func show_slide(index: int) -> void:
	"""Tampilkan slide dengan fade in"""
	if index < 0 or index >= cutscene_data.size():
		finish_cutscene()
		return
	
	current_slide = index
	is_transitioning = true
	
	# Fade out image lama
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(texture_rect, "modulate:a", 0.0, FADE_DURATION / 2.0)
	fade_out_tween.tween_callback(func():
		# Ganti image dan text
		texture_rect.texture = cutscene_data[index]["image"]
		start_typewriter(cutscene_data[index]["text"])
	)
	
	# Fade in image baru
	var fade_in_tween = create_tween()
	fade_in_tween.tween_delay(FADE_DURATION / 2.0)
	fade_in_tween.tween_property(texture_rect, "modulate:a", 1.0, FADE_DURATION / 2.0)
	fade_in_tween.tween_callback(func():
		is_transitioning = false
	)

func next_slide() -> void:
	"""Lanjut ke slide berikutnya"""
	if is_transitioning:
		return
	
	current_slide += 1
	
	if current_slide < cutscene_data.size():
		show_slide(current_slide)
	else:
		finish_cutscene()

# =========================================================
# CUTSCENE FINISH
# =========================================================

func finish_cutscene() -> void:
	"""Selesaikan cutscene dan mulai game"""
	print("✅ Intro Cutscene selesai!")
	
	# Fade out semua UI
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(texture_rect, "modulate:a", 0.0, 1.0)
	tween.tween_property(subtitle_label, "modulate:a", 0.0, 1.0)
	tween.tween_property(continue_hint, "modulate:a", 0.0, 1.0)
	
	tween.tween_callback(func():
		QuestManager.is_intro_done = true
		GameManager.start_game()
		queue_free()
	)
