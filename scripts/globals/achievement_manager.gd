## AchievementManager.gd — VERSI DIPERBAIKI
## Autoload — Mengelola semua data dan logika Achievement.
## Lokasi: res://scripts/globals/achievement_manager.gd
##
## PERBAIKAN:
##   • Tambah print debugging ekstrem di unlock_achievement()
##   • Konfirmasi sinyal dipancarkan dengan print sebelum .emit()
extends Node


# ─────────────────────────────────────────────
# SINYAL
# ─────────────────────────────────────────────

## Dipancarkan saat achievement berhasil di-unlock.
## @param id: String — ID achievement yang di-unlock.
## @param data: Dictionary — Seluruh data achievement tersebut.
signal achievement_unlocked(id: String, data: Dictionary)


# ─────────────────────────────────────────────
# DATABASE ACHIEVEMENT
# ─────────────────────────────────────────────
var achievements: Dictionary = {
	"first_harvest": {
		"id":            "first_harvest",
		"title":         "Panen Pertama",
		"description":   "Berhasil memanen tanaman untuk pertama kalinya.",
		"is_unlocked":   false,
		"unlocked_icon": "res://assets/ui/icons/harvest_icon.png"
	},
	"plant_10": {
		"id":            "plant_10",
		"title":         "Petani Pemula",
		"description":   "Tanam 10 benih di ladang.",
		"is_unlocked":   false,
		"unlocked_icon": "res://assets/ui/icons/seed_icon.png"
	},
	"collect_wood": {
		"id":            "collect_wood",
		"title":         "Penebang Hutan",
		"description":   "Kumpulkan kayu untuk pertama kalinya.",
		"is_unlocked":   false,
		"unlocked_icon": "res://assets/ui/icons/wood_icon.png"
	},
	"fix_ship": {
		"id":            "fix_ship",
		"title":         "Kapten Pulang",
		"description":   "Berhasil memperbaiki kapal dan menyelesaikan game.",
		"is_unlocked":   false,
		"unlocked_icon": "res://assets/ui/icons/ship_icon.png"
	},
	"feed_animal": {
		"id":            "feed_animal",
		"title":         "Sahabat Hewan",
		"description":   "Beri makan hewan peliharaan untuk pertama kalinya.",
		"is_unlocked":   false,
		"unlocked_icon": "res://assets/ui/icons/feed_icon.png"
	},
}


# ─────────────────────────────────────────────
# READY
# ─────────────────────────────────────────────
func _ready() -> void:
	print("🛠️ AchievementManager: _ready() dipanggil. Siap menerima perintah unlock.")


# ─────────────────────────────────────────────
# FUNGSI UNLOCK
# ─────────────────────────────────────────────

## Membuka (unlock) sebuah achievement berdasarkan ID-nya.
## Aman dipanggil berulang kali — tidak akan emit sinyal jika sudah unlock.
func unlock_achievement(id: String) -> void:
	print("🏆 Mencoba unlock Achievement: ", id)

	# Guard: ID tidak dikenal
	if not achievements.has(id):
		push_warning("AchievementManager: ID '%s' tidak ditemukan dalam database! Cek typo/case." % id)
		print("❌ Achievement ID '", id, "' TIDAK ADA dalam database. Daftar ID valid: ", achievements.keys())
		return

	# Guard: sudah di-unlock sebelumnya
	if achievements[id]["is_unlocked"]:
		print("ℹ️ Achievement '", id, "' sudah pernah di-unlock sebelumnya. Skip.")
		return

	# Lakukan unlock
	achievements[id]["is_unlocked"] = true
	print("✅ Quest [", achievements[id]["title"], "] dinyatakan Selesai")
	print("📡 Sinyal achievement_unlocked dipancarkan! — ID: '", id, "', Judul: '", achievements[id]["title"], "'")

	# Pancarkan sinyal → akan diterima oleh AchievementNotification
	achievement_unlocked.emit(id, achievements[id])


## Mengecek apakah sebuah achievement sudah di-unlock.
func is_unlocked(id: String) -> bool:
	if not achievements.has(id):
		return false
	return achievements[id]["is_unlocked"]


# ─────────────────────────────────────────────
# SAVE & LOAD (dipanggil oleh SaveGameManager)
# ─────────────────────────────────────────────

## Mengambil data yang perlu disimpan.
func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	for id in achievements:
		data[id] = achievements[id]["is_unlocked"]
	return data


## Memuat status is_unlocked dari data yang sudah tersimpan.
func load_save_data(data: Dictionary) -> void:
	if data.is_empty():
		return
	for id in data:
		if achievements.has(id):
			achievements[id]["is_unlocked"] = data[id]
	print("[AchievementManager] Data achievement berhasil dimuat.")


## Menyimpan ke file.
func save_to_path(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("AchievementManager: Gagal membuka file untuk ditulis: %s" % path)
		return
	file.store_var(get_save_data())
	file.close()
	print("[AchievementManager] Achievement tersimpan ke: %s" % path)


## Memuat dari file.
func load_from_path(path: String) -> void:
	if not FileAccess.file_exists(path):
		print("[AchievementManager] File save tidak ada (pemain baru): %s" % path)
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("AchievementManager: Gagal membuka file untuk dibaca: %s" % path)
		return
	var data = file.get_var()
	file.close()
	if data is Dictionary:
		load_save_data(data)
