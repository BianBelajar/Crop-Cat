extends Node

# 4 = Selesai bikin pacul, 5 = Dapet bibit & siraman, 6 = Menunggu Pestisida
var quest_step: int = 0

# --- Fungsi Pengecekan Barang (Real dari Inventory) ---
func is_wood_enough() -> bool:
	return InventoryManager.inventory.get("log", 0) >= 10

func is_stone_enough() -> bool:
	return InventoryManager.inventory.get("stone", 0) >= 5

# FUNGSI BARU: Cek Susu & Telur untuk Tukar Pestisida
func can_exchange_pesticide() -> bool:
	var has_egg = InventoryManager.inventory.get("egg", 0) >= 3
	var has_milk = InventoryManager.inventory.get("milk", 0) >= 3
	return has_egg and has_milk

func take_exchange_items() -> void:
	InventoryManager.inventory["egg"] -= 3
	InventoryManager.inventory["milk"] -= 3
	InventoryManager.inventory_changed.emit()
