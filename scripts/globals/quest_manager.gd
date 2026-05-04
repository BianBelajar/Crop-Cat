

extends Node

# ── (semua kode lama dipertahankan persis sama) ──────────────────────────────

const SAVE_PATH = "user://quest_data.save"   # Fallback path lama (tidak dipakai)

signal quest_loaded_signal
signal quest_step_changed(new_step: int)

var quest_step: int = 8:
	set(value):
		quest_step = value
		quest_step_changed.emit(value)

var is_intro_done: bool = false

func is_wood_enough() -> bool:
	return InventoryManager.inventory.get("log", 0) >= 10

func is_stone_enough() -> bool:
	return InventoryManager.inventory.get("stone", 0) >= 5

func can_exchange_pesticide() -> bool:
	var has_egg: bool = InventoryManager.inventory.get("egg", 0) >= 3
	var has_milk: bool = InventoryManager.inventory.get("milk", 0) >= 3
	return has_egg and has_milk

func can_repair_ship() -> bool:
	var has_wood: bool  = InventoryManager.inventory.get("log",    0) >= 15
	var has_stone: bool = InventoryManager.inventory.get("stone",  0) >= 10
	var has_tomato: bool= InventoryManager.inventory.get("tomato", 0) >= 20
	var has_wheat: bool = InventoryManager.inventory.get("wheat",  0) >= 20
	var has_milk: bool  = InventoryManager.inventory.get("milk",   0) >= 10
	var has_egg: bool   = InventoryManager.inventory.get("egg",    0) >= 10
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

func take_wood() -> void:
	if InventoryManager.inventory.has("log"):
		InventoryManager.inventory["log"] -= 10
		InventoryManager.inventory_changed.emit()

func take_stone() -> void:
	if InventoryManager.inventory.has("stone"):
		InventoryManager.inventory["stone"] -= 5
		InventoryManager.inventory_changed.emit()

func take_exchange_items() -> void:
	if InventoryManager.inventory.has("egg") and InventoryManager.inventory.has("milk"):
		InventoryManager.inventory["egg"] -= 3
		InventoryManager.inventory["milk"] -= 3
		InventoryManager.inventory_changed.emit()

func take_ship_repair_items() -> void:
	if can_repair_ship():
		InventoryManager.inventory["log"]    -= 15
		InventoryManager.inventory["stone"]  -= 10
		InventoryManager.inventory["tomato"] -= 20
		InventoryManager.inventory["wheat"]  -= 20
		InventoryManager.inventory["milk"]   -= 10
		InventoryManager.inventory["egg"]    -= 10
		InventoryManager.inventory_changed.emit()

# ── FUNGSI LAMA (dipertahankan sebagai fallback) ─────────────────────────────

func save_quest() -> void:
	save_quest_to_path(SAVE_PATH)

func load_quest() -> void:
	load_quest_from_path(SAVE_PATH)

# ── ⭐ FUNGSI BARU: Path-Aware Save & Load ────────────────────────────────────

## Menyimpan progress quest ke path yang ditentukan (per-user).
func save_quest_to_path(path: String) -> void:
	# Pastikan direktori ada sebelum menulis
	var dir_path: String = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("QuestManager: Gagal membuka file untuk ditulis: " + path)
		return
	file.store_32(quest_step)
	file.store_8(int(is_intro_done))
	print("[QuestManager] Quest tersimpan ke: '%s' (step=%d)" % [path, quest_step])

## Memuat progress quest dari path yang ditentukan (per-user).
func load_quest_from_path(path: String) -> void:
	if not FileAccess.file_exists(path):
		quest_step = 0
		is_intro_done = false
		quest_loaded_signal.emit()
		print("[QuestManager] Tidak ada save quest di: '%s' — mulai dari awal." % path)
		return

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("QuestManager: Gagal membaca file: " + path)
		return

	quest_step     = file.get_32()
	is_intro_done  = bool(file.get_8())
	quest_loaded_signal.emit()
	print("[QuestManager] Quest dimuat dari: '%s' (step=%d)" % [path, quest_step])

func start_ship_repair_quest() -> void:
	if quest_step == 6:
		quest_step = 7
		SaveGameManager.save_game()

func check_and_finish_ship_repair() -> bool:
	if quest_step == 8 and can_repair_ship():
		quest_step = 9
		SaveGameManager.save_game()
		return true
	return false
