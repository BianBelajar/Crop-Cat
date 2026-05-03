extends Node2D

# =====================================================
# FIXED SHIP (Kapal Jadi)
# - Tersembunyi dari awal game
# - Muncul setelah ending (quest_step >= 9)
# =====================================================

func _ready() -> void:
	# Daftarkan ke group agar bisa dikontrol dari ending_cutscene
	add_to_group("fixed_ship")
	
	# Mulai tersembunyi
	_update_visibility(QuestManager.quest_step)
	
	QuestManager.quest_step_changed.connect(_update_visibility)
	QuestManager.quest_loaded_signal.connect(_on_quest_loaded)

func _on_quest_loaded() -> void:
	_update_visibility(QuestManager.quest_step)

func _update_visibility(step: int) -> void:
	visible = step >= 9
