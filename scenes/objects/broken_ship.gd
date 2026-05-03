extends Node2D

# =====================================================
# BROKEN SHIP (Kapal Hancur)
# - Selalu terlihat dari awal game
# - Otomatis tersembunyi setelah ending (quest_step >= 9)
# =====================================================

func _ready() -> void:
	# Daftarkan ke group agar bisa dikontrol dari ending_cutscene
	add_to_group("broken_ship")
	
	# Cek visibility berdasarkan quest step saat ini
	_update_visibility(QuestManager.quest_step)
	
	# Koneksi ke sinyal quest_step_changed
	QuestManager.quest_step_changed.connect(_update_visibility)
	QuestManager.quest_loaded_signal.connect(_on_quest_loaded)

func _on_quest_loaded() -> void:
	_update_visibility(QuestManager.quest_step)

func _update_visibility(step: int) -> void:
	visible = step < 9
