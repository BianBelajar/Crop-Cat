# =============================================================================
# ending_cutscene.gd  —  VERSI DIPERBARUI
# Lokasi: res://scenes/ui/ending_cutscene.gd
#
# PERUBAHAN UTAMA:
#   • Semua pergantian slide kini menggunakan Fade Out → ganti gambar → Fade In
#     via ColorRect ($FadeOverlay) + Tween (tidak ada pergantian instan)
#   • Konstanta durasi fade terpusat (FADE_OUT_DURATION, FADE_IN_DURATION)
#   • Tombol pilihan ("Menjelajah" / "Menetap") mendapat animasi kemunculan
#   • Tidak ada perubahan pada alur cerita atau slide content
#
# PANDUAN INSPECTOR — TOMBOL PILIHAN (BtnExplore & BtnStay):
# ────────────────────────────────────────────────────────────
# 1. Pilih tombol → Inspector → Theme Overrides → Styles
#    • normal  → [New StyleBoxFlat]
#      bg_color      : Color(0.15, 0.45, 0.60)   ← biru-toska
#      corner_radius : 14 (semua sudut)
#      content_margin: 12 atas/bawah, 24 kiri/kanan
#    • hover   → StyleBoxFlat: bg_color Color(0.20, 0.60, 0.78)
#    • pressed → StyleBoxFlat: bg_color Color(0.10, 0.32, 0.45)
#    • focus   → StyleBoxFlat: border_width 2, border_color Color(1,1,1,0.6)
#
# 2. Font outline:
#    Theme Overrides → Font → (drag font resource)
#    Theme Overrides → Constants → outline_size: 2
#    Theme Overrides → Colors  → font_outline_color: Color(0,0,0,0.8)
#
# 3. Minimum size tombol: Layout → Custom Minimum Size → x:200 y:52
# =============================================================================
extends CanvasLayer

# ── Konstanta Fade ────────────────────────────────────────────────────────────
const FADE_OUT_DURATION: float = 0.60   # Layar menghitam
const FADE_IN_DURATION: float  = 0.80   # Gambar baru muncul

# ── Data Slide ────────────────────────────────────────────────────────────────
var repair_slides: Array = [
	{"image": "res://assets/ending/perbaikan_1.png", "text": "Dengan bahan yang kamu kumpulkan, Mbah Kucing mulai bekerja keras memperbaiki kapalmu..."},
	{"image": "res://assets/ending/perbaikan_2.png", "text": "Hari demi hari berlalu... suara palu dan kayu memenuhi pesisir Pulau Harapan."},
	{"image": "res://assets/ending/perbaikan_3.png", "text": "Kapalmu akhirnya berdiri megah di tepi pantai! Sebuah karya yang luar biasa."},
]
var explore_slides: Array = [
	{"image": "res://assets/ending/jelajah_1.png", "text": "Dengan berat hati, kamu berpamitan dengan Mbah Kucing yang sudah seperti keluarga..."},
	{"image": "res://assets/ending/jelajah_2.png", "text": "Layar terkembang, angin berhembus, kapalmu berlayar meninggalkan Pulau Harapan..."},
	{"image": "res://assets/ending/jelajah_3.png", "text": "Lautan luas memanggilmu kembali. Petualangan baru menanti, Meong! Sampai jumpa!"},
]
var stay_slides: Array = [
	{"image": "res://assets/ending/tinggal_1.png", "text": "Kamu memilih untuk tinggal. Pulau Harapan adalah rumahmu sekarang..."},
	{"image": "res://assets/ending/tinggal_2.png", "text": "Bersama Mbah Kucing, kamu terus membangun pulau kecil yang penuh kehidupan ini..."},
	{"image": "res://assets/ending/tinggal_3.png", "text": "Pulau Harapan kini menjadi surga yang subur dan makmur. Selamat, Meong!"},
]

# ── State ─────────────────────────────────────────────────────────────────────
enum Phase { REPAIR, CHOICE, OUTCOME, TAMAT, CREDITS }
var current_phase: Phase = Phase.REPAIR
var current_slide_index: int = 0
var is_transitioning: bool = false
var typewriter_done: bool = true
var typewriter_tween: Tween = null
var chosen_ending: String = ""

# ── Node refs ─────────────────────────────────────────────────────────────────
@onready var texture_rect      = $TextureRect
@onready var subtitle_panel    = $SubtitlePanel
@onready var subtitle_label    = $SubtitlePanel/SubtitleLabel
@onready var hint_label        = $HintLabel
@onready var choice_panel      = $ChoicePanel
@onready var tamat_panel       = $TamatPanel
@onready var tamat_desc        = $TamatPanel/TamatDesc
@onready var credits_panel     = $CreditsPanel
@onready var credits_text      = $CreditsPanel/CreditsText
@onready var btn_final_menu    = $CreditsPanel/BtnFinalMenu
## ColorRect warna hitam menutupi seluruh layar — pastikan sudah ada di scene!
@onready var fade_overlay      = $FadeOverlay

# =============================================================================
# INIT
# =============================================================================
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100

	choice_panel.visible  = false
	tamat_panel.visible   = false
	credits_panel.visible = false
	btn_final_menu.visible = false
	hint_label.visible    = false

	# Mulai dari hitam penuh, lalu fade in ke slide pertama
	fade_overlay.color = Color(0, 0, 0, 1)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_start_repair_phase()

# =============================================================================
# SHOW SLIDE — semua slide wajib lewat fungsi ini
# =============================================================================
func _show_slide(slides: Array, index: int) -> void:
	is_transitioning = true
	typewriter_done  = false
	subtitle_label.text = ""
	hint_label.visible  = false

	# Ganti gambar saat layar masih hitam
	var img_path: String = slides[index].get("image", "")
	if img_path != "" and ResourceLoader.exists(img_path):
		texture_rect.texture = load(img_path)
	else:
		texture_rect.texture = null

	# Fade In (hitam → transparan)
	var tween: Tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), FADE_IN_DURATION)
	await tween.finished
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	is_transitioning = false
	_start_typewriter(slides[index]["text"])

# =============================================================================
# TRANSISI ANTAR SLIDE — Fade Out → ganti → Fade In
# =============================================================================
func _transition_to_next(callback: Callable) -> void:
	## Helper: Fade Out → jalankan callback (ganti konten) → Fade In via _show_slide.
	is_transitioning = true

	var tween_out: Tween = create_tween()
	tween_out.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), FADE_OUT_DURATION)
	await tween_out.finished

	callback.call()

# =============================================================================
# TYPEWRITER
# =============================================================================
func _start_typewriter(text: String) -> void:
	if typewriter_tween and typewriter_tween.is_valid():
		typewriter_tween.kill()
	typewriter_done = false
	subtitle_label.text = ""
	typewriter_tween = create_tween()

	for i in range(text.length()):
		typewriter_tween.tween_callback(func(): subtitle_label.text = text.substr(0, i + 1))
		typewriter_tween.tween_interval(0.04)

	typewriter_tween.tween_callback(func():
		typewriter_done = true
		hint_label.visible = true
	)

# =============================================================================
# INPUT
# =============================================================================
func _input(event: InputEvent) -> void:
	if is_transitioning or current_phase in [Phase.CHOICE, Phase.TAMAT, Phase.CREDITS]:
		return

	var is_advance: bool = event.is_action_pressed("ui_accept") or \
		(event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	if not is_advance:
		return

	var current_slides: Array = _get_current_slides()

	if not typewriter_done:
		if typewriter_tween:
			typewriter_tween.kill()
		subtitle_label.text = current_slides[current_slide_index]["text"]
		typewriter_done    = true
		hint_label.visible = true
	else:
		_trigger_next_step()

func _get_current_slides() -> Array:
	if current_phase == Phase.REPAIR:
		return repair_slides
	return explore_slides if chosen_ending == "jelajah" else stay_slides

# =============================================================================
# FASE REPAIR
# =============================================================================
func _start_repair_phase() -> void:
	current_phase      = Phase.REPAIR
	current_slide_index = 0
	_show_slide(repair_slides, current_slide_index)

func _trigger_next_step() -> void:
	if current_phase == Phase.REPAIR:
		_next_slide(repair_slides, _show_choice_screen)
	elif current_phase == Phase.OUTCOME:
		var slides: Array = _get_current_slides()
		_next_slide(slides, _show_tamat_screen)

func _next_slide(slides: Array, on_end: Callable) -> void:
	## Fade Out → increment index → Fade In (atau jalankan on_end jika selesai).
	_transition_to_next(func():
		current_slide_index += 1
		if current_slide_index < slides.size():
			_show_slide(slides, current_slide_index)
		else:
			on_end.call()
	)

# =============================================================================
# FASE PILIHAN
# =============================================================================
func _show_choice_screen() -> void:
	current_phase = Phase.CHOICE
	subtitle_panel.visible = false
	hint_label.visible     = false

	# Fade sedikit (ke alpha 0.4) agar gambar latar masih kelihatan samar
	var tween: Tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 0.4), 0.5)
	await tween.finished

	choice_panel.modulate = Color(1, 1, 1, 0)
	choice_panel.visible  = true
	var appear: Tween = create_tween()
	appear.tween_property(choice_panel, "modulate", Color(1, 1, 1, 1), 0.4) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_btn_explore_pressed() -> void:
	chosen_ending = "jelajah"
	_start_outcome_phase()

func _on_btn_stay_pressed() -> void:
	chosen_ending = "tinggal"
	_start_outcome_phase()

# =============================================================================
# FASE OUTCOME
# =============================================================================
func _start_outcome_phase() -> void:
	current_phase       = Phase.OUTCOME
	current_slide_index = 0
	choice_panel.visible  = false
	subtitle_panel.visible = true

	# Fade out pilihan → Fade in slide outcome pertama
	var tween: Tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), FADE_OUT_DURATION)
	await tween.finished

	var slides: Array = _get_current_slides()
	_show_slide(slides, current_slide_index)

# =============================================================================
# FASE TAMAT
# =============================================================================
func _show_tamat_screen() -> void:
	current_phase = Phase.TAMAT
	subtitle_panel.visible = false

	for node in get_tree().get_nodes_in_group("broken_ship"): node.visible = false
	for node in get_tree().get_nodes_in_group("fixed_ship"):  node.visible = true

	if chosen_ending == "jelajah":
		tamat_desc.text = "Meong berlayar kembali menjelajahi lautan Nusantara yang luas.\nTerima kasih sudah bermain Harvest Paws!"
	else:
		tamat_desc.text = "Meong memilih Pulau Harapan sebagai rumahnya selamanya.\nTerima kasih sudah bermain Harvest Paws!"
		QuestManager.save_quest()

	# Fade out → tampilkan TamatPanel → Fade in
	var tween_out: Tween = create_tween()
	tween_out.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 1.0)
	await tween_out.finished

	tamat_panel.visible = true
	var tween_in: Tween = create_tween()
	tween_in.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), 1.0)

# =============================================================================
# FASE CREDITS
# =============================================================================
func _on_btn_menu_pressed() -> void:
	_start_credits_animation()

func _start_credits_animation() -> void:
	current_phase = Phase.CREDITS

	var tween_out: Tween = create_tween()
	tween_out.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 1.0)
	await tween_out.finished

	tamat_panel.visible    = false
	credits_panel.visible  = true
	btn_final_menu.visible = false

	var screen_height: float = get_viewport().get_visible_rect().size.y
	credits_text.position.y = screen_height

	var tween_in: Tween = create_tween()
	tween_in.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), 1.0)
	await tween_in.finished

	var scroll: Tween = create_tween()
	scroll.tween_property(credits_text, "position:y", -1500.0, 20.0)
	await scroll.finished

	# Tombol kembali ke menu muncul setelah credits selesai
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Pastikan tidak blokir klik
	btn_final_menu.visible  = true
	btn_final_menu.modulate = Color(1, 1, 1, 0)
	btn_final_menu.mouse_filter = Control.MOUSE_FILTER_STOP  # Pastikan tombol bisa diklik
	var btn_tween: Tween = create_tween()
	btn_tween.tween_property(btn_final_menu, "modulate", Color(1, 1, 1, 1), 1.0)

func _on_btn_final_menu_pressed() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 0.8)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/ui/game_menu_screen.tscn")
	queue_free()
