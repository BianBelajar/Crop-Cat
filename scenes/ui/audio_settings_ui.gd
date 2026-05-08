## audio_settings_ui.gd
## Tempel script ini ke node root AudioSettingsUI (CanvasLayer)
## Script ini sudah disesuaikan dengan struktur scene yang ada.
extends CanvasLayer

# ─── Node References ─────────────────────────────────────────────
@onready var music_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MusicSlider
@onready var sfx_slider: HSlider   = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/SFXSlider
@onready var close_button: Button  = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/CloseButton
@onready var save_button: Button   = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/SaveButton

# ─── Throttle untuk preview SFX ──────────────────────────────────
var _sfx_preview_timer: float = 0.0


func _ready() -> void:
	# PENTING: pastikan node ini tidak ikut freeze saat game di-pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Isi slider dari nilai AudioManager yang sudah di-load
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.step      = 0.01
	music_slider.value     = AudioManager.music_volume
	
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step      = 0.01
	sfx_slider.value     = AudioManager.sfx_volume
	
	# Hubungkan signal slider
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	
	# Hubungkan signal tombol
	save_button.pressed.connect(_on_save_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	
	# Pause game saat settings dibuka
	get_tree().paused = true


func _exit_tree() -> void:
	# Resume game saat node ini dihapus dari tree
	get_tree().paused = false


func _process(delta: float) -> void:
	if _sfx_preview_timer > 0.0:
		_sfx_preview_timer -= delta


# ─── Signal Handlers ──────────────────────────────────────────────

func _on_music_slider_changed(value: float) -> void:
	# AudioManager.music_volume setter sudah handle linear_to_db()
	AudioManager.music_volume = value


func _on_sfx_slider_changed(value: float) -> void:
	AudioManager.sfx_volume = value
	# Preview suara saat slider digeser (throttle 0.5 detik)
	if _sfx_preview_timer <= 0.0:
		_sfx_preview_timer = 0.5
		# Opsional: putar preview SFX di sini jika ada file-nya
		# AudioManager.play_sfx(preload("res://audio/sfx/..."))


func _on_save_button_pressed() -> void:
	# Simpan ke file konfigurasi lewat AudioManager
	AudioManager.save_audio_settings()
	# Feedback visual: ubah teks tombol sementara
	save_button.text     = "✓ Tersimpan!"
	save_button.disabled = true
	await get_tree().create_timer(1.2).timeout
	# Guard: pastikan node belum dihapus saat timer selesai
	if is_instance_valid(save_button):
		save_button.text     = "Simpan"
		save_button.disabled = false


func _on_close_button_pressed() -> void:
	# Auto-save sebelum tutup (biar tidak perlu klik Simpan dulu)
	AudioManager.save_audio_settings()
	queue_free()
