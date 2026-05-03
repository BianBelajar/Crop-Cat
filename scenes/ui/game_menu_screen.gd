extends CanvasLayer

@onready var save_game_button: Button = $MarginContainer/MainButtons/SaveGameButton
@onready var start_game_button: Button = $MarginContainer/MainButtons/StartGameButton
@onready var load_game_button: Button = $MarginContainer/MainButtons/LoadGameButton
@onready var main_buttons: VBoxContainer = $MarginContainer/MainButtons
@onready var difficulty_buttons: VBoxContainer = $MarginContainer/DifficultyButtons


func _ready() -> void:
	save_game_button.disabled = !SaveGameManager.allow_save_game
	save_game_button.focus_mode = SaveGameManager.allow_save_game if Control.FOCUS_ALL else Control.FOCUS_NONE 
	
	if SaveGameManager.allow_save_game:
		start_game_button.text = "Resume"
		
	var save_path = "user://game_data/save_Level1_game_data.tres"
	load_game_button.disabled = !FileAccess.file_exists(save_path)
	
	# --- TAMBAHAN UNTUK DIFFICULTY ---
	difficulty_buttons.hide()
	main_buttons.show()


func _on_start_game_button_pressed() -> void:
	# CEK APAKAH GAME SUDAH BERJALAN?
	if SaveGameManager.allow_save_game:
		# Jika sudah (artinya ini Resume), jangan ke menu Difficulty!
		# Langsung tutup layarnya saja
		queue_free()
	else:
		# Jika game baru pertama kali dibuka, JANGAN panggil start_game dulu.
		# Sembunyikan menu utama, munculkan menu difficulty!
		main_buttons.hide()
		difficulty_buttons.show()


func _on_save_game_button_pressed() -> void:
	SaveGameManager.save_game()
	
func _on_load_game_button_pressed() -> void:
	GameManager.load_saved_game()
	queue_free()

# INI YANG TERTINGGAL: Fungsi untuk tombol Exit
func _on_exit_game_button_pressed() -> void:
	GameManager.exit_game()

func _on_easy_button_pressed() -> void:
	DifficultyManager.set_difficulty(DifficultyManager.Level.EASY)
	start_the_actual_game()

func _on_normal_button_pressed() -> void:
	DifficultyManager.set_difficulty(DifficultyManager.Level.NORMAL)
	start_the_actual_game()

func _on_hard_button_pressed() -> void:
	DifficultyManager.set_difficulty(DifficultyManager.Level.HARD)
	start_the_actual_game()

func start_the_actual_game() -> void:
	GameManager.start_game()
	queue_free()
