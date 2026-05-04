extends CanvasLayer

# =====================================================
# DATA GAMBAR & TEKS
# =====================================================
var repair_slides: Array = [
	{"image": "res://assets/ending/perbaikan_1.png", "text": "Dengan bahan yang kamu kumpulkan, Mbah Kucing mulai bekerja keras memperbaiki kapalmu..."},
	{"image": "res://assets/ending/perbaikan_2.png", "text": "Hari demi hari berlalu... suara palu dan kayu memenuhi pesisir Pulau Harapan."},
	{"image": "res://assets/ending/perbaikan_3.png", "text": "Kapalmu akhirnya berdiri megah di tepi pantai! Sebuah karya yang luar biasa."}
]

var explore_slides: Array = [
	{"image": "res://assets/ending/jelajah_1.png", "text": "Dengan berat hati, kamu berpamitan dengan Mbah Kucing yang sudah seperti keluarga..."},
	{"image": "res://assets/ending/jelajah_2.png", "text": "Layar terkembang, angin berhembus, kapalmu berlayar meninggalkan Pulau Harapan..."},
	{"image": "res://assets/ending/jelajah_3.png", "text": "Lautan luas memanggilmu kembali. Petualangan baru menanti, Meong! Sampai jumpa!"}
]

var stay_slides: Array = [
	{"image": "res://assets/ending/tinggal_1.png", "text": "Kamu memilih untuk tinggal. Pulau Harapan adalah rumahmu sekarang..."},
	{"image": "res://assets/ending/tinggal_2.png", "text": "Bersama Mbah Kucing, kamu terus membangun pulau kecil yang penuh kehidupan ini..."},
	{"image": "res://assets/ending/tinggal_3.png", "text": "Pulau Harapan kini menjadi surga yang subur dan makmur. Selamat, Meong!"}
]

# =====================================================
# STATE & REFERENSI NODE
# =====================================================
enum Phase { REPAIR, CHOICE, OUTCOME, TAMAT, CREDITS }
var current_phase: Phase = Phase.REPAIR
var current_slide_index: int = 0
var is_transitioning: bool = false
var typewriter_done: bool = true
var typewriter_tween: Tween = null
var chosen_ending: String = "" 

@onready var texture_rect = $TextureRect
@onready var subtitle_panel = $SubtitlePanel
@onready var subtitle_label = $SubtitlePanel/SubtitleLabel
@onready var hint_label = $HintLabel
@onready var choice_panel = $ChoicePanel
@onready var tamat_panel = $TamatPanel
@onready var tamat_desc = $TamatPanel/TamatDesc
@onready var credits_panel = $CreditsPanel
@onready var credits_text = $CreditsPanel/CreditsText
@onready var btn_final_menu = $CreditsPanel/BtnFinalMenu # Tombol baru
@onready var fade_overlay = $FadeOverlay

# =====================================================
# INITIALIZATION
# =====================================================
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	
	choice_panel.visible = false
	tamat_panel.visible = false
	credits_panel.visible = false
	btn_final_menu.visible = false # Pastikan tombol ini sembunyi
	hint_label.visible = false
	
	fade_overlay.color = Color(0, 0, 0, 1)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_start_repair_phase()

func _start_repair_phase() -> void:
	current_phase = Phase.REPAIR
	current_slide_index = 0
	_show_slide(repair_slides, current_slide_index)

# =====================================================
# LOGIKA SLIDE & TYPEWRITER
# =====================================================
func _show_slide(slides: Array, index: int) -> void:
	is_transitioning = true
	typewriter_done = false
	subtitle_label.text = ""
	hint_label.visible = false

	var img_path: String = slides[index].get("image", "")
	if img_path != "" and ResourceLoader.exists(img_path):
		texture_rect.texture = load(img_path)
	else:
		texture_rect.texture = null 

	var tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), 0.8)
	await tween.finished

	is_transitioning = false
	_start_typewriter(slides[index]["text"])

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

# =====================================================
# INPUT HANDLER
# =====================================================
func _input(event: InputEvent) -> void:
	if is_transitioning or current_phase == Phase.CHOICE or current_phase == Phase.TAMAT or current_phase == Phase.CREDITS:
		return

	var is_advance = event.is_action_pressed("ui_accept") or \
		(event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	
	if not is_advance: return

	var current_slides = repair_slides if current_phase == Phase.REPAIR else \
		(explore_slides if chosen_ending == "jelajah" else stay_slides)

	if not typewriter_done:
		if typewriter_tween: typewriter_tween.kill()
		subtitle_label.text = current_slides[current_slide_index]["text"]
		typewriter_done = true
		hint_label.visible = true
	else:
		_trigger_next_step()

func _trigger_next_step() -> void:
	if current_phase == Phase.REPAIR:
		_next_repair_slide()
	elif current_phase == Phase.OUTCOME:
		_next_outcome_slide()

func _next_repair_slide() -> void:
	is_transitioning = true
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 0.6)
	await tween.finished

	current_slide_index += 1
	if current_slide_index < repair_slides.size():
		_show_slide(repair_slides, current_slide_index)
	else:
		_show_choice_screen()

# =====================================================
# FASE PILIHAN ENDING
# =====================================================
func _show_choice_screen() -> void:
	current_phase = Phase.CHOICE
	subtitle_panel.visible = false
	hint_label.visible = false

	var tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 0.4), 0.5)
	await tween.finished

	choice_panel.modulate = Color(1, 1, 1, 0)
	choice_panel.visible = true
	var appear_tween = create_tween()
	appear_tween.tween_property(choice_panel, "modulate", Color(1, 1, 1, 1), 0.4)

func _on_btn_explore_pressed() -> void:
	chosen_ending = "jelajah"
	_start_outcome_phase()

func _on_btn_stay_pressed() -> void:
	chosen_ending = "tinggal"
	_start_outcome_phase()

# =====================================================
# FASE ENDING SESUAI PILIHAN
# =====================================================
func _start_outcome_phase() -> void:
	current_phase = Phase.OUTCOME
	current_slide_index = 0
	choice_panel.visible = false
	subtitle_panel.visible = true

	var tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 0.5)
	await tween.finished
	
	var slides = explore_slides if chosen_ending == "jelajah" else stay_slides
	_show_slide(slides, current_slide_index)

func _next_outcome_slide() -> void:
	is_transitioning = true
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 0.6)
	await tween.finished

	current_slide_index += 1
	var slides = explore_slides if chosen_ending == "jelajah" else stay_slides
	
	if current_slide_index < slides.size():
		_show_slide(slides, current_slide_index)
	else:
		_show_tamat_screen()

# =====================================================
# FASE TAMAT & CREDITS
# =====================================================
func _show_tamat_screen() -> void:
	current_phase = Phase.TAMAT
	subtitle_panel.visible = false
	
	for node in get_tree().get_nodes_in_group("broken_ship"): node.visible = false
	for node in get_tree().get_nodes_in_group("fixed_ship"): node.visible = true

	if chosen_ending == "jelajah":
		tamat_desc.text = "Meong berlayar kembali menjelajahi lautan Nusantara yang luas.\nTerima kasih sudah bermain Crop Cat!"
	else:
		tamat_desc.text = "Meong memilih Pulau Harapan sebagai rumahnya selamanya.\nTerima kasih sudah bermain Crop Cat!"
		QuestManager.save_quest()

	var tween_out = create_tween()
	tween_out.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 1.0)
	await tween_out.finished

	tamat_panel.visible = true
	var tween_in = create_tween()
	tween_in.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), 1.0)

func _on_btn_menu_pressed() -> void:
	_start_credits_animation()

func _start_credits_animation() -> void:
	current_phase = Phase.CREDITS
	
	var tween_out = create_tween()
	tween_out.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 1.0)
	await tween_out.finished

	tamat_panel.visible = false
	credits_panel.visible = true
	btn_final_menu.visible = false # Masih sembunyi
	
	var screen_height = get_viewport().get_visible_rect().size.y
	credits_text.position.y = screen_height

	var tween_in = create_tween()
	tween_in.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), 1.0)
	await tween_in.finished

	# Rolling Credits
	var scroll_tween = create_tween()
	scroll_tween.tween_property(credits_text, "position:y", -1500.0, 20.0)
	await scroll_tween.finished

	# --- BAGIAN BARU: MEMUNCULKAN TOMBOL SETELAH CREDIT BERES ---
	btn_final_menu.visible = true
	btn_final_menu.modulate = Color(1, 1, 1, 0)
	var btn_tween = create_tween()
	btn_tween.tween_property(btn_final_menu, "modulate", Color(1, 1, 1, 1), 1.0)

# FUNGSI UNTUK TOMBOL BARU TERAKHIR
func _on_btn_final_menu_pressed() -> void:
	var tween_final = create_tween()
	tween_final.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 0.8)
	await tween_final.finished

	get_tree().change_scene_to_file("res://scenes/ui/game_menu_screen.tscn")
	queue_free()
