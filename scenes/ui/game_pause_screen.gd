## game_pause_screen.gd
## Scene  : res://scenes/ui/game_pause_screen.tscn
## Extends: CanvasLayer
##
## FIX 1: Semua path node tombol diperbaiki agar cocok dengan nama di .tscn:
##         ResumeButton     → ResumeGameButton
##         SaveButton       → SaveGameButton
##         SettingButton    → AudioSettingsButton
## FIX 2: Sinyal tombol dihubungkan via kode di _ready() karena .tscn
##         tidak memiliki [connection] sama sekali.
##
## ⚠ INSPECTOR — WAJIB diatur:
##   • CanvasLayer > Process Mode = "Always"   (sudah benar di .tscn: process_mode = 3)
##   • CanvasLayer > Layer = 10                (sudah benar di .tscn: layer = 10)

extends CanvasLayer

# ─────────────────────────────────────────────
# NODE REFERENCES
# ✅ Nama node disesuaikan dengan yang ada di .tscn
# ─────────────────────────────────────────────
@onready var resume_button    : Button  = $MarginContainer/VBoxContainer/ResumeGameButton
@onready var save_button      : Button  = $MarginContainer/VBoxContainer/SaveGameButton
@onready var setting_button   : Button  = $MarginContainer/VBoxContainer/AudioSettingsButton
@onready var main_menu_button : Button  = $MarginContainer/VBoxContainer/MainMenuButton

# Panel untuk animasi slide
@onready var panel : Control = $MarginContainer

# ─────────────────────────────────────────────
# LIFECYCLE
# ─────────────────────────────────────────────
func _ready() -> void:
	# ✅ FIX: Hubungkan sinyal secara manual karena .tscn tidak punya [connection]
	resume_button.pressed.connect(_on_resume_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	setting_button.pressed.connect(_on_setting_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)

	# Pastikan game benar-benar terpause saat menu ini muncul
	get_tree().paused = true

	# Nonaktifkan Save jika memang tidak boleh disimpan
	save_button.disabled   = not SaveGameManager.allow_save_game
	save_button.focus_mode = Control.FOCUS_ALL if SaveGameManager.allow_save_game \
							 else Control.FOCUS_NONE

	# Sembunyikan HUD supaya tidak overlap
	_set_hud_visibility(false)

	# Animasi masuk: panel meluncur dari bawah
	_animate_in()

	# Fokus ke tombol Resume supaya bisa dikontrol gamepad/keyboard
	resume_button.grab_focus()


func _exit_tree() -> void:
	# Kembalikan visibilitas HUD saat menu ini dihapus dari tree
	_set_hud_visibility(true)


# ─────────────────────────────────────────────
# TOMBOL
# ─────────────────────────────────────────────

## Resume — lanjutkan game, hapus pause menu
func _on_resume_button_pressed() -> void:
	_unpause_and_close()


## Save — simpan game tanpa keluar dari pause menu
func _on_save_button_pressed() -> void:
	if SaveGameManager.allow_save_game:
		SaveGameManager.save_game()
		# Feedback singkat: nonaktifkan tombol sebentar
		save_button.disabled = true
		save_button.text = "Tersimpan ✓"
		await get_tree().create_timer(1.5).timeout
		# Cek apakah node masih valid setelah await (bisa saja sudah queue_free)
		if not is_instance_valid(save_button):
			return
		save_button.disabled = false
		save_button.text = "Save"


## Setting — buka panel audio/pengaturan di atas pause menu
func _on_setting_button_pressed() -> void:
	var settings_scene := preload("res://scenes/ui/audio_settings_ui.tscn")
	var instance := settings_scene.instantiate()
	# Tambahkan sebagai sibling agar berdiri sendiri di root
	get_tree().root.add_child(instance)


## Main Menu — unpause, lalu minta GameManager kembali ke menu utama
func _on_main_menu_button_pressed() -> void:
	main_menu_button.disabled = true

	# ✅ PENTING: Unpause DULU sebelum GameManager melakukan apa pun.
	#   Jika tidak, semua proses (termasuk fade Tween) akan freeze.
	get_tree().paused = false

	# Serahkan ke GameManager: fade → bersihkan scene → tampilkan MainMenu
	GameManager.return_to_game_menu()

	# Hapus diri sendiri — HUD juga ikut tersembunyi via _exit_tree()
	queue_free()


# ─────────────────────────────────────────────
# HELPERS INTERNAL
# ─────────────────────────────────────────────

func _unpause_and_close() -> void:
	get_tree().paused = false
	_animate_out()


func _set_hud_visibility(visible_state: bool) -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.visible = visible_state


## Animasi masuk: panel slide dari bawah + fade-in
func _animate_in() -> void:
	if not is_instance_valid(panel):
		return
	panel.modulate.a = 0.0
	panel.position.y += 40.0
	var tween := create_tween().set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(panel, "modulate:a", 1.0, 0.25) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(panel, "position:y", panel.position.y - 40.0, 0.25) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


## Animasi keluar: panel fade-out, lalu queue_free
func _animate_out() -> void:
	if not is_instance_valid(panel):
		queue_free()
		return
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(panel, "modulate:a", 0.0, 0.2) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	queue_free()
