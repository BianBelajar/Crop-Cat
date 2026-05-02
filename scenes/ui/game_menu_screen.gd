extends CanvasLayer

@onready var save_game_button: Button = $MarginContainer/VBoxContainer/SaveGameButton
@onready var start_game_button: Button = $MarginContainer/VBoxContainer/StartGameButton
@onready var load_game_button: Button = $MarginContainer/VBoxContainer/LoadGameButton


func _ready() -> void:
	save_game_button.disabled = !SaveGameManager.allow_save_game
	save_game_button.focus_mode = SaveGameManager.allow_save_game if Control.FOCUS_ALL else Control.FOCUS_NONE 
	
	if SaveGameManager.allow_save_game:
		start_game_button.text = "Resume"
		
	var save_path = "user://game_data/save_Level1_game_data.tres"
	load_game_button.disabled = !FileAccess.file_exists(save_path)


func _on_start_game_button_pressed() -> void:
	# CEK APAKAH GAME SUDAH BERJALAN?
	if SaveGameManager.allow_save_game:
		# Jika sudah, cukup tutup layarnya (Resume), jangan panggil start_game() lagi!
		queue_free()
	else:
		# Jika game baru pertama kali dibuka, jalankan proses muat level
		GameManager.start_game()
		queue_free()


func _on_save_game_button_pressed() -> void:
	SaveGameManager.save_game()
	
	
func _on_load_game_button_pressed() -> void:
	GameManager.load_saved_game()
	queue_free()


# INI YANG TERTINGGAL: Fungsi untuk tombol Exit
func _on_exit_game_button_pressed() -> void:
	GameManager.exit_game()
