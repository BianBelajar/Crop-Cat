extends Node
# =============================================================================
# quest_manager.gd — VERSI DIPERBAIKI
# Lokasi: res://scripts/globals/quest_manager.gd
#
# PERBAIKAN KRITIS:
#   • Tambah pemanggilan AchievementManager.unlock_achievement() di setiap
#     titik quest yang relevan (jembatan Quest → Achievement yang hilang).
#   • Tambah print debugging ekstrem di semua titik krusial.
# =============================================================================

const SAVE_PATH = "user://quest_data.save"

signal quest_loaded_signal
signal quest_step_changed(new_step: int)

var quest_step: int = 0:
	set(value):
		quest_step = value
		quest_step_changed.emit(value)
		# Cek achievement hanya setelah _ready() selesai
		if is_node_ready():
			_check_achievements_for_step(value)

var is_intro_done: bool = false

# ── JURNAL QUEST ──────────────────────────────────────────────────────────────
var clue_quest_aktif: String = ""
var _popup_jurnal_instance: Node = null
const POPUP_SCENE_PATH: String = "res://scenes/ui/education_popup.tscn"


func _ready() -> void:
	print("🛠️ QuestManager: _ready() dipanggil. quest_step saat ini: ", quest_step)


# =============================================================================
# ⭐ FUNGSI BARU — JEMBATAN QUEST → ACHIEVEMENT
# Dipanggil otomatis setiap kali quest_step berubah.
# =============================================================================
func _check_achievements_for_step(step: int) -> void:
	print("🛠️ QuestManager: _check_achievements_for_step() dipanggil untuk step: ", step)
	match step:
		# Step 3: player sudah berhasil mengumpulkan 10 kayu (selesaikan quest kayu)
		3:
			print("🏆 Mencoba unlock Achievement: collect_wood")
			AchievementManager.unlock_achievement("collect_wood")
		# Step 4: player sudah dapat cangkul (berarti batu sudah dikumpulkan)
		4:
			pass  # Tidak ada achievement khusus untuk ini
		# Step 5: Farming kit diberikan → berarti player siap bertani
		5:
			pass
		# Step 9: Kapal berhasil diperbaiki → Achievement fix_ship
		9:
			print("🏆 Mencoba unlock Achievement: fix_ship")
			AchievementManager.unlock_achievement("fix_ship")
		_:
			pass


# =============================================================================
# FUNGSI PENGAMBILAN ITEM (take_wood, take_stone, dll.)
# Unlock achievement di sini karena inilah titik "quest selesai" yang sesungguhnya
# =============================================================================

func take_wood() -> void:
	print("✅ Quest [Kumpulkan 10 Kayu] dinyatakan Selesai — mengambil kayu dari inventaris")
	if InventoryManager.inventory.has("log"):
		InventoryManager.inventory["log"] -= 10
		InventoryManager.inventory_changed.emit()
	# Unlock achievement penebang hutan
	print("🏆 Mencoba unlock Achievement: collect_wood")
	AchievementManager.unlock_achievement("collect_wood")

func take_stone() -> void:
	print("✅ Quest [Kumpulkan 5 Batu] dinyatakan Selesai — mengambil batu dari inventaris")
	if InventoryManager.inventory.has("stone"):
		InventoryManager.inventory["stone"] -= 5
		InventoryManager.inventory_changed.emit()

func take_exchange_items() -> void:
	print("✅ Quest [Tukar Telur & Susu] dinyatakan Selesai")
	if InventoryManager.inventory.has("egg") and InventoryManager.inventory.has("milk"):
		InventoryManager.inventory["egg"] -= 3
		InventoryManager.inventory["milk"] -= 3
		InventoryManager.inventory_changed.emit()

func take_ship_repair_items() -> void:
	print("✅ Quest [Perbaiki Kapal] dinyatakan Selesai — mengambil semua bahan kapal")
	if can_repair_ship():
		InventoryManager.inventory["log"]    -= 15
		InventoryManager.inventory["stone"]  -= 10
		InventoryManager.inventory["tomato"] -= 20
		InventoryManager.inventory["wheat"]  -= 20
		InventoryManager.inventory["milk"]   -= 10
		InventoryManager.inventory["egg"]    -= 10
		InventoryManager.inventory_changed.emit()
		# Unlock achievement kapal
		print("🏆 Mencoba unlock Achievement: fix_ship")
		AchievementManager.unlock_achievement("fix_ship")


# =============================================================================
# FUNGSI DIPANGGIL DARI LUAR (oleh sistem lain, bukan dari dialogue)
# =============================================================================

## Dipanggil dari collectible/harvest system saat tanaman pertama kali dipanen
func notify_first_harvest() -> void:
	print("✅ Quest [Panen Pertama] dicatat")
	print("🏆 Mencoba unlock Achievement: first_harvest")
	AchievementManager.unlock_achievement("first_harvest")

## Counter total bibit yang sudah ditanam (tomat + gandum)
var _total_planted: int = 0

## Dipanggil dari tomato.gd dan wheat.gd setiap kali bibit ditanam.
## Otomatis unlock achievement saat mencapai 10.
func notify_planted() -> void:
	_total_planted += 1
	print("🌱 Total bibit ditanam: ", _total_planted, " / 10")
	if _total_planted >= 10:
		print("✅ Quest [Tanam 10 Bibit] dinyatakan Selesai")
		print("🏆 Mencoba unlock Achievement: plant_10")
		AchievementManager.unlock_achievement("plant_10")

## Dipanggil dari feed_component saat hewan pertama kali diberi makan
func notify_fed_animal() -> void:
	print("✅ Quest [Beri Makan Hewan] dicatat")
	print("🏆 Mencoba unlock Achievement: feed_animal")
	AchievementManager.unlock_achievement("feed_animal")


# =============================================================================
# JURNAL QUEST
# =============================================================================

func tampilkan_jurnal() -> void:
	if is_instance_valid(_popup_jurnal_instance):
		_popup_jurnal_instance.tutup_jurnal()
		_popup_jurnal_instance = null
		return

	if clue_quest_aktif.is_empty():
		return

	if not ResourceLoader.exists(POPUP_SCENE_PATH):
		push_warning("QuestManager: Scene popup tidak ditemukan!")
		return

	var popup = load(POPUP_SCENE_PATH).instantiate()
	Engine.get_main_loop().root.add_child(popup)
	popup.show_fact(clue_quest_aktif)
	_popup_jurnal_instance = popup
	popup.tree_exited.connect(func(): _popup_jurnal_instance = null)

func set_clue(teks: String) -> void:
	clue_quest_aktif = teks

func set_clue_dan_tampilkan(teks: String) -> void:
	print("🛠️ Dialog Selesai diproses — set_clue_dan_tampilkan dipanggil")
	clue_quest_aktif = teks
	if is_instance_valid(_popup_jurnal_instance):
		_popup_jurnal_instance.queue_free()
		_popup_jurnal_instance = null
	tampilkan_jurnal()


# =============================================================================
# PENGECEKAN INVENTARIS
# =============================================================================

func is_wood_enough() -> bool:
	return InventoryManager.inventory.get("log", 0) >= 10

func is_stone_enough() -> bool:
	return InventoryManager.inventory.get("stone", 0) >= 5

func can_exchange_pesticide() -> bool:
	var has_egg: bool = InventoryManager.inventory.get("egg", 0) >= 3
	var has_milk: bool = InventoryManager.inventory.get("milk", 0) >= 3
	return has_egg and has_milk

func can_repair_ship() -> bool:
	var has_wood: bool   = InventoryManager.inventory.get("log",    0) >= 15
	var has_stone: bool  = InventoryManager.inventory.get("stone",  0) >= 10
	var has_tomato: bool = InventoryManager.inventory.get("tomato", 0) >= 20
	var has_wheat: bool  = InventoryManager.inventory.get("wheat",  0) >= 20
	var has_milk: bool   = InventoryManager.inventory.get("milk",   0) >= 10
	var has_egg: bool    = InventoryManager.inventory.get("egg",    0) >= 10
	return has_wood and has_stone and has_tomato and has_wheat and has_milk and has_egg

func get_ship_repair_progress() -> Dictionary:
	return {
		"wood":         InventoryManager.inventory.get("log", 0),
		"wood_needed":  15,
		"stone":        InventoryManager.inventory.get("stone", 0),
		"stone_needed": 10,
		"tomato":       InventoryManager.inventory.get("tomato", 0),
		"tomato_needed":20,
		"wheat":        InventoryManager.inventory.get("wheat", 0),
		"wheat_needed": 20,
		"milk":         InventoryManager.inventory.get("milk", 0),
		"milk_needed":  10,
		"egg":          InventoryManager.inventory.get("egg", 0),
		"egg_needed":   10,
	}

func is_ship_repair_active() -> bool:
	return quest_step >= 7 and quest_step <= 9


# =============================================================================
# SAVE & LOAD
# =============================================================================

func save_quest() -> void:
	save_quest_to_path(SAVE_PATH)

func load_quest() -> void:
	load_quest_from_path(SAVE_PATH)

func save_quest_to_path(path: String) -> void:
	var dir_path: String = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("QuestManager: Gagal membuka file untuk ditulis: " + path)
		return
	file.store_32(quest_step)
	file.store_8(int(is_intro_done))
	file.store_pascal_string(clue_quest_aktif)
	print("[QuestManager] Quest tersimpan ke: '%s' (step=%d)" % [path, quest_step])

func load_quest_from_path(path: String) -> void:
	if not FileAccess.file_exists(path):
		quest_step    = 0
		is_intro_done = false
		clue_quest_aktif = ""
		quest_loaded_signal.emit()
		print("[QuestManager] Tidak ada save quest di: '%s' — mulai dari awal." % path)
		return

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("QuestManager: Gagal membaca file: " + path)
		return

	quest_step       = file.get_32()
	is_intro_done    = bool(file.get_8())
	clue_quest_aktif = file.get_pascal_string()
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
