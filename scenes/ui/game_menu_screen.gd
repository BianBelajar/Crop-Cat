## game_menu_screen.gd
extends CanvasLayer

@onready var save_game_button: Button          = $MarginContainer/MainButtons/SaveGameButton
@onready var start_game_button: Button         = $MarginContainer/MainButtons/StartGameButton
@onready var load_game_button: Button          = $MarginContainer/MainButtons/LoadGameButton
@onready var logout_button: Button             = $MarginContainer/MainButtons/LogoutButton
@onready var exit_game_button: Button          = $MarginContainer/MainButtons/ExitGameButton  # ← BARU
@onready var main_buttons: VBoxContainer       = $MarginContainer/MainButtons
@onready var difficulty_buttons: VBoxContainer = $MarginContainer/DifficultyButtons

func _ready() -> void:
	save_game_button.disabled   = not SaveGameManager.allow_save_game
	save_game_button.focus_mode = Control.FOCUS_ALL if SaveGameManager.allow_save_game else Control.FOCUS_NONE

	if SaveGameManager.allow_save_game:
		start_game_button.text = "Resume"

	var has_save: bool = SaveGameManager.current_user_has_any_save()
	load_game_button.disabled = not has_save

	if not SaveGameManager.current_username.is_empty():
		var title: Label = get_node_or_null("MarginContainer/TitleLabel")
		if title:
			title.text = "Menu — " + SaveGameManager.current_username

	difficulty_buttons.hide()
	main_buttons.show()

	# ── Label tombol berubah sesuai konteks ──────────────────────────────────
	if SaveGameManager.allow_save_game:
		exit_game_button.text = "Main Menu"   # sedang in-game
	else:
		exit_game_button.text = "Exit"        # belum main / sudah kembali ke menu

	# Sembunyikan HUD saat menu dibuka
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.hide()

func _exit_tree() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show()

# ── Tombol Exit / Main Menu ──────────────────────────────────────────────────
func _on_exit_game_button_pressed() -> void:
	if SaveGameManager.allow_save_game:
		# Sedang in-game → fade ke hitam dulu, lalu ke Game Menu
		exit_game_button.disabled = true   # cegah double-click
		await _fade_to_black(0.45)
		queue_free()
		GameManager.return_to_game_menu()
	else:
		# Belum/sudah keluar dari game → tutup aplikasi
		get_tree().quit()

# ── Transisi fade ke hitam ───────────────────────────────────────────────────
func _fade_to_black(duration: float) -> void:
	# Buat overlay hitam di atas segalanya
	var overlay_layer := CanvasLayer.new()
	overlay_layer.layer = 128          # paling atas
	get_tree().root.add_child(overlay_layer)

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)  # mulai transparan
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_layer.add_child(overlay)

	# Tween alpha 0 → 1
	var tween := create_tween()
	tween.tween_property(overlay, "color:a", 1.0, duration)\
		 .set_ease(Tween.EASE_IN)\
		 .set_trans(Tween.TRANS_QUAD)
	await tween.finished
	# overlay_layer otomatis ikut terhapus saat scene berganti

# ── Fungsi lainnya (tidak diubah) ────────────────────────────────────────────
func _on_start_game_button_pressed() -> void:
	if SaveGameManager.allow_save_game:
		queue_free()
	else:
		main_buttons.hide()
		difficulty_buttons.show()

func _on_save_game_button_pressed() -> void:
	SaveGameManager.save_game()

func _on_load_game_button_pressed() -> void:
	GameManager.load_saved_game()
	queue_free()

func _on_audio_settings_button_pressed() -> void:
	var settings_scene := preload("res://scenes/ui/audio_settings_ui.tscn")
	var instance := settings_scene.instantiate()
	get_tree().root.add_child(instance)

func _on_logout_button_pressed() -> void:
	queue_free()
	GameManager.return_to_login()

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
