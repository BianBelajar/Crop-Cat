extends Node
# =============================================================================
# game_dialogue_manager.gd — VERSI DIPERBAIKI
# Lokasi: res://scripts/globals/game_dialogue_manager.gd
#
# PERBAIKAN:
#   • Tambah print debugging di setiap fungsi action_*
#   • Panggil QuestManager.notify_* untuk trigger achievement dari aksi dialogue
# =============================================================================

# --- DAFTAR SINYAL ---
signal feed_the_animals
signal give_axe
signal give_hoe
signal give_farming_kit
signal unlock_pesticide
signal start_ship_repair
signal trigger_ending


# --- DAFTAR FUNGSI (Dipanggil dari file .dialogue dengan "do") ---

func action_feed_animals() -> void:
	print("🛠️ Dialog Selesai diproses — action_feed_animals()")
	feed_the_animals.emit()
	# Trigger achievement memberi makan hewan
	print("🏆 Mencoba unlock Achievement: feed_animal (via action_feed_animals)")
	AchievementManager.unlock_achievement("feed_animal")

func action_give_axe() -> void:
	print("🛠️ Dialog Selesai diproses — action_give_axe()")
	give_axe.emit()

func action_give_hoe() -> void:
	print("🛠️ Dialog Selesai diproses — action_give_hoe()")
	give_hoe.emit()

func action_give_farming_kit() -> void:
	print("🛠️ Dialog Selesai diproses — action_give_farming_kit()")
	give_farming_kit.emit()

func action_give_crop_seeds() -> void:
	print("🛠️ Dialog Selesai diproses — action_give_crop_seeds()")
	# Dipanggil dari guide.dialogue saat player setuju untuk mulai bertani

func action_unlock_pesticide() -> void:
	print("🛠️ Dialog Selesai diproses — action_unlock_pesticide()")
	unlock_pesticide.emit()

func action_start_ship_repair() -> void:
	print("🛠️ Dialog Selesai diproses — action_start_ship_repair()")
	start_ship_repair.emit()
	print("🚢 Quest Perbaikan Kapal dimulai!")

func action_trigger_ending() -> void:
	print("🛠️ Dialog Selesai diproses — action_trigger_ending()")
	trigger_ending.emit()
	print("🎬 Ending dipicu! Memuat ending cutscene...")
