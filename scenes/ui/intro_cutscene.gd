extends Control

# =====================================================
# INTRO CUTSCENE - Versi Baru
# Fitur: Fade In/Out antar frame + Typewriter Text
# =====================================================

@onready var texture_rect: TextureRect = $TextureRect
@onready var subtitle_label: Label = $Panel/Label

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

var current_slide: int = 0
var is_transitioning: bool = false
var typewriter_done: bool = true
var typewriter_tween: Tween = null

# Node overlay (dibuat secara programatik, tidak perlu edit .tscn)
var fade_overlay: ColorRect = null

# =====================================================
# SETUP AWAL
# =====================================================

func _ready() -> void:
	_build_fade_overlay()
	subtitle_label.text = ""
	show_slide(current_slide)

func _build_fade_overlay() -> void:
	# Buat layer hitam di atas semua node (untuk efek fade)
	fade_overlay = ColorRect.new()
	fade_overlay.name = "FadeOverlay"
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_overlay.color = Color(0.0, 0.0, 0.0, 1.0)  # Mulai hitam penuh
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Jangan blok input
	add_child(fade_overlay)

# =====================================================
# INPUT: KLIK / SPASI UNTUK LANJUT
# =====================================================

func _input(event: InputEvent) -> void:
	# Jangan proses input saat sedang transisi fade
	if is_transitioning:
		return

	var is_advance = event.is_action_pressed("ui_accept") or \
		(event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)

	if is_advance:
		if not typewriter_done:
			# Typewriter masih berjalan → skip langsung ke teks penuh
			_skip_typewriter()
		else:
			# Teks sudah selesai → lanjut ke frame berikutnya
			_next_slide()

# =====================================================
# TAMPILKAN SLIDE
# =====================================================

func show_slide(index: int) -> void:
	is_transitioning = true
	subtitle_label.text = ""
	typewriter_done = false

	# Ganti gambar (masih tertutup FadeOverlay yang hitam)
	texture_rect.texture = cutscene_data[index]["image"]

	# === FADE IN: Hitam → Transparan ===
	var tween_in = create_tween()
	tween_in.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), 0.9) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	await tween_in.finished

	is_transitioning = false

	# Mulai efek typewriter setelah gambar muncul
	_start_typewriter(cutscene_data[index]["text"])

# =====================================================
# EFEK TYPEWRITER
# =====================================================

func _start_typewriter(text: String) -> void:
	if typewriter_tween and typewriter_tween.is_valid():
		typewriter_tween.kill()

	subtitle_label.text = ""
	typewriter_done = false
	typewriter_tween = create_tween()

	for i in range(text.length()):
		typewriter_tween.tween_callback(_set_label_char.bind(text, i + 1))
		typewriter_tween.tween_interval(0.038)  # Kecepatan ketik (detik per karakter)

	# Tandai selesai setelah semua karakter tampil
	typewriter_tween.tween_callback(func(): typewriter_done = true)

func _set_label_char(text: String, count: int) -> void:
	subtitle_label.text = text.substr(0, count)

func _skip_typewriter() -> void:
	if typewriter_tween and typewriter_tween.is_valid():
		typewriter_tween.kill()
	subtitle_label.text = cutscene_data[current_slide]["text"]
	typewriter_done = true

# =====================================================
# TRANSISI KE SLIDE BERIKUTNYA
# =====================================================

func _next_slide() -> void:
	is_transitioning = true

	# === FADE OUT: Transparan → Hitam ===
	var tween_out = create_tween()
	tween_out.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 0.65) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	await tween_out.finished

	current_slide += 1

	if current_slide < cutscene_data.size():
		show_slide(current_slide)
	else:
		_finish_cutscene()

# =====================================================
# SELESAI: MASUK KE GAME
# =====================================================

func _finish_cutscene() -> void:
	print("✅ Intro Cutscene selesai, masuk ke game utama!")
	QuestManager.is_intro_done = true
	GameManager.start_game()
	queue_free()
