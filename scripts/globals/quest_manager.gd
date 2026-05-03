extends Node

const SAVE_PATH = "user://quest_data.save"
signal quest_loaded_signal
# DAFTAR TAHAPAN QUEST:
# 0 = Awal (Belum punya apa-apa, Mbah minta 10 Kayu)
# 1 = Sedang mengumpulkan 10 Kayu
# 2 = Kayu terkumpul (Mbah minta 5 Batu untuk bikin Pacul)
# 3 = Sedang mengumpulkan 5 Batu
# 4 = Batu terkumpul (Mbah kasih Pacul, Alat Siram, Bibit & suruh ke Pedagang)
# 5 = Sedang mengumpulkan 3 Telur & 3 Susu untuk Pedagang
# 6 = Pestisida terbuka (Quest Selesai)

var quest_step: int = 0

# =========================================================
# FUNGSI PENGECEKAN (Real Time dari InventoryManager)
# =========================================================

# Cek apakah Kayu (log) sudah cukup 10
func is_wood_enough() -> bool:
	return InventoryManager.inventory.get("log", 0) >= 10

# Cek apakah Batu (stone) sudah cukup 5
func is_stone_enough() -> bool:
	return InventoryManager.inventory.get("stone", 0) >= 5

# Cek apakah syarat tukar Pestisida sudah cukup (3 Telur & 3 Susu)
func can_exchange_pesticide() -> bool:
	var has_egg = InventoryManager.inventory.get("egg", 0) >= 3
	var has_milk = InventoryManager.inventory.get("milk", 0) >= 3
	return has_egg and has_milk


# =========================================================
# FUNGSI PENGAMBILAN BARANG (MENGURANGI ISI TAS)
# =========================================================

# Mbah Kucing mengambil 10 Kayu
func take_wood() -> void:
	if InventoryManager.inventory.has("log"):
		InventoryManager.inventory["log"] -= 10
		InventoryManager.inventory_changed.emit() # Update angka di UI Layar
		print("Quest: 10 Kayu diserahkan.")

# Mbah Kucing mengambil 5 Batu
func take_stone() -> void:
	if InventoryManager.inventory.has("stone"):
		InventoryManager.inventory["stone"] -= 5
		InventoryManager.inventory_changed.emit() # Update angka di UI Layar
		print("Quest: 5 Batu diserahkan.")

# Pedagang mengambil 3 Telur dan 3 Susu
func take_exchange_items() -> void:
	if InventoryManager.inventory.has("egg") and InventoryManager.inventory.has("milk"):
		InventoryManager.inventory["egg"] -= 3
		InventoryManager.inventory["milk"] -= 3
		InventoryManager.inventory_changed.emit() # Update angka di UI Layar
		print("Quest: Telur & Susu diserahkan ke Pedagang.")

func save_quest() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_32(quest_step)
	print("Progress Cerita Tersimpan! Tahap: ", quest_step)

func load_quest() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		quest_step = file.get_32()
		print("Progress Cerita Dimuat! Tahap: ", quest_step)
	else:
		quest_step = 0 
		
	# ---> 2. TAMBAHKAN BARIS INI DI PALING BAWAH FUNGSI LOAD:
	quest_loaded_signal.emit()
