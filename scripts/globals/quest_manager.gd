extends Node

const SAVE_PATH = "user://quest_data.save"

# =====================================================
# SINYAL
# =====================================================
signal quest_loaded_signal
signal quest_step_changed(new_step: int)  # ⭐ BARU: Dipancarkan saat quest_step berubah

# =====================================================
# DAFTAR TAHAPAN QUEST:
# =====================================================
# 0 = Awal (Belum punya apa-apa, Mbah minta 10 Kayu)
# 1 = Sedang mengumpulkan 10 Kayu
# 2 = Kayu terkumpul (Mbah minta 5 Batu untuk bikin Pacul)
# 3 = Sedang mengumpulkan 5 Batu
# 4 = Batu terkumpul (Mbah kasih Pacul, Alat Siram, Bibit & suruh ke Pedagang)
# 5 = Sedang mengumpulkan 3 Telur & 3 Susu untuk Pedagang
# 6 = Pestisida terbuka (Quest Awal Selesai)
# =====================================================
# 7 = Perbaikan Kapal dimulai ⭐
# 8 = Sedang mengumpulkan resources untuk kapal ⭐
# 9 = Semua resources terkumpul / Ending terpicu ⭐
# =====================================================

# ⭐ Property setter: otomatis emit sinyal saat quest_step berubah
var quest_step: int = 0:
	set(value):
		quest_step = value
		quest_step_changed.emit(value)

var is_intro_done: bool = false

# =========================================================
# FUNGSI PENGECEKAN QUEST AWAL (Real Time)
# =========================================================

func is_wood_enough() -> bool:
	return InventoryManager.inventory.get("log", 0) >= 10

func is_stone_enough() -> bool:
	return InventoryManager.inventory.get("stone", 0) >= 5

func can_exchange_pesticide() -> bool:
	var has_egg = InventoryManager.inventory.get("egg", 0) >= 3
	var has_milk = InventoryManager.inventory.get("milk", 0) >= 3
	return has_egg and has_milk


# =========================================================
# FUNGSI PENGECEKAN QUEST PERBAIKAN KAPAL ⭐
# =========================================================

func can_repair_ship() -> bool:
	var has_wood = InventoryManager.inventory.get("log", 0) >= 20
	var has_stone = InventoryManager.inventory.get("stone", 0) >= 15
	var has_tomato = InventoryManager.inventory.get("tomato", 0) >= 20
	var has_wheat = InventoryManager.inventory.get("wheat", 0) >= 20
	var has_milk = InventoryManager.inventory.get("milk", 0) >= 10
	var has_egg = InventoryManager.inventory.get("egg", 0) >= 10
	
	return has_wood and has_stone and has_tomato and has_wheat and has_milk and has_egg

func get_ship_repair_progress() -> Dictionary:
	return {
		"wood": InventoryManager.inventory.get("log", 0),
		"wood_needed": 20,
		"stone": InventoryManager.inventory.get("stone", 0),
		"stone_needed": 15,
		"tomato": InventoryManager.inventory.get("tomato", 0),
		"tomato_needed": 20,
		"wheat": InventoryManager.inventory.get("wheat", 0),
		"wheat_needed": 20,
		"milk": InventoryManager.inventory.get("milk", 0),
		"milk_needed": 10,
		"egg": InventoryManager.inventory.get("egg", 0),
		"egg_needed": 10,
	}

func is_ship_repair_active() -> bool:
	return quest_step >= 7 and quest_step <= 9

# =========================================================
# FUNGSI PENGAMBILAN BARANG (MENGURANGI ISI TAS)
# =========================================================

func take_wood() -> void:
	if InventoryManager.inventory.has("log"):
		InventoryManager.inventory["log"] -= 10
		InventoryManager.inventory_changed.emit()
		print("Quest: 10 Kayu diserahkan.")

func take_stone() -> void:
	if InventoryManager.inventory.has("stone"):
		InventoryManager.inventory["stone"] -= 5
		InventoryManager.inventory_changed.emit()
		print("Quest: 5 Batu diserahkan.")

func take_exchange_items() -> void:
	if InventoryManager.inventory.has("egg") and InventoryManager.inventory.has("milk"):
		InventoryManager.inventory["egg"] -= 3
		InventoryManager.inventory["milk"] -= 3
		InventoryManager.inventory_changed.emit()
		print("Quest: Telur & Susu diserahkan ke Pedagang.")

func take_ship_repair_items() -> void:
	if can_repair_ship():
		InventoryManager.inventory["log"] -= 20
		InventoryManager.inventory["stone"] -= 15
		InventoryManager.inventory["tomato"] -= 20
		InventoryManager.inventory["wheat"] -= 20
		InventoryManager.inventory["milk"] -= 10
		InventoryManager.inventory["egg"] -= 10
		InventoryManager.inventory_changed.emit()
		print("Quest: Semua resources untuk perbaikan kapal diserahkan!")
	else:
		print("ERROR: Resources belum cukup untuk perbaikan kapal!")

# =========================================================
# FUNGSI SAVE & LOAD
# =========================================================

func save_quest() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_32(quest_step)
	print("Progress Cerita Tersimpan! Tahap: ", quest_step)

func load_quest() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		# Gunakan assignment langsung tanpa setter saat loading untuk hindari side effect
		quest_step = file.get_32()
		print("Progress Cerita Dimuat! Tahap: ", quest_step)
	else:
		quest_step = 0 
		
	quest_loaded_signal.emit()

func start_ship_repair_quest() -> void:
	if quest_step == 6:
		quest_step = 7
		save_quest()
		print("Quest Perbaikan Kapal dimulai! Quest Step: 7")

func check_and_finish_ship_repair() -> bool:
	if quest_step == 8 and can_repair_ship():
		quest_step = 9
		save_quest()
		print("Semua resources terkumpul! Siap untuk ending. Quest Step: 9")
		return true
	return false
