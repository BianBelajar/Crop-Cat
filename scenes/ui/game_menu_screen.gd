## main_menu.gd
## Scene  : res://scenes/ui/main_menu.tscn
## Extends: CanvasLayer
##
## Gunakan scene asli game_menu_screen.tscn sebagai basis,
## lalu ganti script-nya dengan file ini.
## Struktur node yang dipakai:
##   MarginContainer/MainButtons/StartGameButton
##   MarginContainer/MainButtons/LoadGameButton
##   MarginContainer/MainButtons/SaveGameButton
##   MarginContainer/MainButtons/AudioSettingsButton
##   MarginContainer/MainButtons/LogoutButton
##   MarginContainer/DifficultyButtons/EasyButton
##   MarginContainer/DifficultyButtons/NormalButton
##   MarginContainer/DifficultyButtons/HardButton
##   MarginContainer/MarginContainer/Label   ← judul/nama user

extends CanvasLayer

# ─────────────────────────────────────────────
# NODE REFERENCES — cocok dengan struktur game_menu_screen.tscn
# ─────────────────────────────────────────────
@onready var start_button   : Button        = $MarginContainer/MainButtons/StartGameButton
@onready var load_button    : Button        = $MarginContainer/MainButtons/LoadGameButton
@onready var save_button    : Button        = $MarginContainer/MainButtons/SaveGameButton
@onready var setting_button : Button        = $MarginContainer/MainButtons/AudioSettingsButton
@onready var logout_button  : Button        = $MarginContainer/MainButtons/LogoutButton
@onready var difficulty_box : VBoxContainer = $MarginContainer/DifficultyButtons
@onready var main_box       : VBoxContainer = $MarginContainer/MainButtons
@onready var title_label: Label = $CenterContainer/Panel/MarginContainer/MainVBox/TitleLabel

# ─────────────────────────────────────────────
# LIFECYCLE
# ─────────────────────────────────────────────
func _ready() -> void:
	difficulty_box.hide()
	main_box.show()

	if not SaveGameManager.current_username.is_empty():
		title_label.text = SaveGameManager.current_username

	save_button.disabled   = not SaveGameManager.allow_save_game
	save_button.focus_mode = Control.FOCUS_ALL if SaveGameManager.allow_save_game \
							 else Control.FOCUS_NONE

	var has_save: bool = SaveGameManager.current_user_has_any_save()
	load_button.disabled   = not has_save
	load_button.focus_mode = Control.FOCUS_ALL if has_save else Control.FOCUS_NONE

	_animate_in()
	start_button.grab_focus()


# ─────────────────────────────────────────────
# TOMBOL — nama fungsi harus cocok dengan sinyal di scene
# ─────────────────────────────────────────────

func _on_start_game_button_pressed() -> void:
	main_box.hide()
	difficulty_box.show()

func _on_load_game_button_pressed() -> void:
	load_button.disabled = true
	GameManager.load_saved_game()
	queue_free()

func _on_save_game_button_pressed() -> void:
	if SaveGameManager.allow_save_game:
		SaveGameManager.save_game()
		save_button.text = "Tersimpan ✓"
		save_button.disabled = true
		await get_tree().create_timer(1.5).timeout
		save_button.disabled = false
		save_button.text = "Save"

func _on_audio_settings_button_pressed() -> void:
	var settings_scene := preload("res://scenes/ui/audio_settings_ui.tscn")
	var instance := settings_scene.instantiate()
	get_tree().root.add_child(instance)

func _on_logout_button_pressed() -> void:
	logout_button.disabled = true
	queue_free()
	GameManager.return_to_login()

# ─────────────────────────────────────────────
# DIFFICULTY
# ─────────────────────────────────────────────

func _on_easy_button_pressed() -> void:
	DifficultyManager.set_difficulty(DifficultyManager.Level.EASY)
	_start_the_actual_game()

func _on_normal_button_pressed() -> void:
	DifficultyManager.set_difficulty(DifficultyManager.Level.NORMAL)
	_start_the_actual_game()

func _on_hard_button_pressed() -> void:
	DifficultyManager.set_difficulty(DifficultyManager.Level.HARD)
	_start_the_actual_game()

func _start_the_actual_game() -> void:
	QuestManager.quest_step = 0
	SaveGameManager.save_game()
	get_tree().change_scene_to_file("res://scenes/ui/intro_cutscene.tscn")
	queue_free()

# ─────────────────────────────────────────────
# ANIMASI
# ─────────────────────────────────────────────

func _animate_in() -> void:
	# CanvasLayer tidak punya modulate — pakai child pertama
	var root_control: CanvasItem = get_child(0)
	if not is_instance_valid(root_control):
		return
	root_control.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(root_control, "modulate:a", 1.0, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
