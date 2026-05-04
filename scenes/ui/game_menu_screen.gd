## game_menu_screen.gd  (MODIFIKASI)
## Perubahan: deteksi file save kini menggunakan path per-user dari SaveGameManager.
extends CanvasLayer

@onready var save_game_button: Button      = $MarginContainer/MainButtons/SaveGameButton
@onready var start_game_button: Button     = $MarginContainer/MainButtons/StartGameButton
@onready var load_game_button: Button      = $MarginContainer/MainButtons/LoadGameButton
@onready var logout_button: Button         = $MarginContainer/MainButtons/LogoutButton
@onready var main_buttons: VBoxContainer   = $MarginContainer/MainButtons
@onready var difficulty_buttons: VBoxContainer = $MarginContainer/DifficultyButtons

func _ready() -> void:
	# ⭐ Tombol Save hanya aktif jika game sedang berjalan
	save_game_button.disabled    = not SaveGameManager.allow_save_game
	save_game_button.focus_mode  = Control.FOCUS_ALL if SaveGameManager.allow_save_game else Control.FOCUS_NONE

	if SaveGameManager.allow_save_game:
		start_game_button.text = "Resume"

	# ⭐ Cek file save menggunakan path per-user
	var has_save: bool = SaveGameManager.current_user_has_any_save()
	load_game_button.disabled = not has_save

	# ⭐ Tampilkan nama user di judul menu jika sudah login
	if not SaveGameManager.current_username.is_empty():
		var title: Label = get_node_or_null("MarginContainer/TitleLabel")
		if title:
			title.text = "Menu — " + SaveGameManager.current_username

	difficulty_buttons.hide()
	main_buttons.show()


func _on_start_game_button_pressed() -> void:
	if SaveGameManager.allow_save_game:
		queue_free()  # Resume — tutup menu saja
	else:
		main_buttons.hide()
		difficulty_buttons.show()


func _on_save_game_button_pressed() -> void:
	SaveGameManager.save_game()


func _on_load_game_button_pressed() -> void:
	GameManager.load_saved_game()
	queue_free()


func _on_exit_game_button_pressed() -> void:
	GameManager.exit_game()


func _on_logout_button_pressed() -> void:
	## ⭐ BARU: Tombol Logout — kembali ke layar Login
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
