extends Node

# --- DAFTAR SINYAL ---
signal feed_the_animals    # <- Ini yang tadi hilang dan bikin error
signal give_axe 
signal give_hoe
signal give_farming_kit
signal unlock_pesticide

# --- DAFTAR FUNGSI (Untuk dipanggil dari file .dialogue) ---

func action_feed_animals() -> void:
	feed_the_animals.emit()

func action_give_axe() -> void:
	give_axe.emit()

func action_give_hoe() -> void:
	give_hoe.emit()

func action_give_farming_kit() -> void:
	give_farming_kit.emit()

func action_unlock_pesticide() -> void:
	unlock_pesticide.emit()
