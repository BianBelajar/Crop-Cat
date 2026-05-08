## audio_settings_ui.gd
## UI pengaturan volume Music dan SFX.
## Hubungkan ke AudioManager untuk mengubah volume bus secara real-time.
extends CanvasLayer

# ─── Node References ────────────────────────────────────────────
@onready var panel_container: PanelContainer = $PanelContainer
@onready var margin_container: MarginContainer = $PanelContainer/MarginContainer
@onready var v_box_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer
@onready var music_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/SFXSlider
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/CloseButton
@onready var save_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/SaveButton
@onready var label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label

# Label persentase (opsional, buat UX lebih baik)
@onready var music_label_pct: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MusicPctLabel
@onready var sfx_label_pct:   Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/SFXPctLabel


func _ready() -> void:
	# Isi nilai slider dari AudioManager saat panel dibuka
	music_slider.value = AudioManager.music_volume
	sfx_slider.value   = AudioManager.sfx_volume
	
	_update_music_label(music_slider.value)
	_update_sfx_label(sfx_slider.value)
	
	# Hubungkan sinyal
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	save_button.pressed.connect(_on_save_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	
	# Pause game saat settings dibuka (opsional)
	get_tree().paused = true


func _exit_tree() -> void:
	# Resume game saat settings ditutup
	get_tree().paused = false


# ─────────────────────────────────────────────────────────────────
# SIGNAL HANDLERS
# ─────────────────────────────────────────────────────────────────

func _on_music_slider_changed(value: float) -> void:
	# Ubah volume Music bus secara real-time
	AudioManager.music_volume = value
	_update_music_label(value)

func _on_sfx_slider_changed(value: float) -> void:
	# Ubah volume SFX bus secara real-time
	AudioManager.sfx_volume = value
	_update_sfx_label(value)
	# Putar SFX preview saat geser slider
	_play_sfx_preview()

func _on_save_button_pressed() -> void:
	AudioManager.save_audio_settings()
	# Tampilkan feedback visual singkat
	save_button.text = "✓ Tersimpan!"
	save_button.disabled = true
	await get_tree().create_timer(1.2).timeout
	if is_instance_valid(save_button):
		save_button.text = "Simpan"
		save_button.disabled = false

func _on_close_button_pressed() -> void:
	# Simpan otomatis saat ditutup
	AudioManager.save_audio_settings()
	queue_free()


# ─────────────────────────────────────────────────────────────────
# HELPER
# ─────────────────────────────────────────────────────────────────

func _update_music_label(value: float) -> void:
	if is_instance_valid(music_label_pct):
		music_label_pct.text = "%d%%" % roundi(value * 100)

func _update_sfx_label(value: float) -> void:
	if is_instance_valid(sfx_label_pct):
		sfx_label_pct.text = "%d%%" % roundi(value * 100)

func _play_sfx_preview() -> void:
	# Putar salah satu SFX sebagai preview saat slider SFX digeser
	# Throttle agar tidak spam
	if _sfx_preview_timer > 0.0:
		return
	_sfx_preview_timer = 0.5
	var preview_sfx: AudioStream = preload("res://assets/audio/sfx/chicken-cluck-1.ogg")
	AudioManager.play_sfx(preview_sfx)

var _sfx_preview_timer: float = 0.0

func _process(delta: float) -> void:
	if _sfx_preview_timer > 0.0:
		_sfx_preview_timer -= delta
