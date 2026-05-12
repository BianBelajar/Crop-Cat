## AchievementManager.gd
## Autoload — Mengelola semua data dan logika Achievement.
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
## Kunci = ID unik achievement (String).
## Nilai = Dictionary berisi semua properti.
##
## Untuk locked_icon: gunakan path ikon gembok/misteri.
## Untuk unlocked_icon: gunakan path ikon asli item/aksi.
## Ganti path ikon sesuai aset yang ada di project-mu.
var achievements: Dictionary = {
	"first_harvest": {
		"id":             "first_harvest",
		"title":          "Panen Pertama",
		"description":    "Berhasil memanen tanaman untuk pertama kalinya.",
		"is_unlocked":    false,
		"unlocked_icon":  "res://assets/ui/icons/harvest_icon.png"
	},
	"plant_10": {
		"id":             "plant_10",
		"title":          "Petani Pemula",
		"description":    "Tanam 10 benih di ladang.",
		"is_unlocked":    false,
		"unlocked_icon":  "res://assets/ui/icons/seed_icon.png"
	},
	"collect_wood": {
		"id":             "collect_wood",
		"title":          "Penebang Hutan",
		"description":    "Kumpulkan kayu untuk pertama kalinya.",
		"is_unlocked":    false,
		"unlocked_icon":  "res://assets/ui/icons/wood_icon.png"
	},
	"fix_ship": {
		"id":             "fix_ship",
		"title":          "Kapten Pulang",
		"description":    "Berhasil memperbaiki kapal dan menyelesaikan game.",
		"is_unlocked":    false,
		"unlocked_icon":  "res://assets/ui/icons/ship_icon.png"
	},
	"feed_animal": {
		"id":             "feed_animal",
		"title":          "Sahabat Hewan",
		"description":    "Beri makan hewan peliharaan untuk pertama kalinya.",
		"is_unlocked":    false,
		"unlocked_icon":  "res://assets/ui/icons/feed_icon.png"
	},
}


# ─────────────────────────────────────────────
# FUNGSI UNLOCK
# ─────────────────────────────────────────────

## Membuka (unlock) sebuah achievement berdasarkan ID-nya.
## Aman dipanggil berulang kali — tidak akan emit sinyal jika sudah unlock.
func unlock_achievement(id: String) -> void:
	if not achievements.has(id):
		push_warning("AchievementManager: ID '%s' tidak ditemukan!" % id)
		return

	# Guard: jangan lakukan apa-apa jika sudah di-unlock sebelumnya
	if achievements[id]["is_unlocked"]:
		return

	achievements[id]["is_unlocked"] = true
	print("[AchievementManager] Achievement terbuka: '%s'" % achievements[id]["title"])
	achievement_unlocked.emit(id, achievements[id])


## Mengecek apakah sebuah achievement sudah di-unlock.
func is_unlocked(id: String) -> bool:
	if not achievements.has(id):
		return false
	return achievements[id]["is_unlocked"]


# ─────────────────────────────────────────────
# SAVE & LOAD (dipanggil oleh SaveGameManager)
# ─────────────────────────────────────────────

## Mengambil data yang perlu disimpan: hanya status is_unlocked tiap achievement.
## Mengembalikan Dictionary { "first_harvest": true, "plant_10": false, ... }
func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	for id in achievements:
		data[id] = achievements[id]["is_unlocked"]
	return data


## Memuat status is_unlocked dari data yang sudah tersimpan.
## @param data: Dictionary dari get_save_data()
func load_save_data(data: Dictionary) -> void:
	if data.is_empty():
		return
	for id in data:
		if achievements.has(id):
			# Muat status langsung tanpa emit sinyal (ini proses load, bukan unlock baru)
			achievements[id]["is_unlocked"] = data[id]
	print("[AchievementManager] Data achievement berhasil dimuat.")


## Menyimpan ke file. Dipanggil oleh SaveGameManager.save_game().
func save_to_path(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("AchievementManager: Gagal membuka file untuk ditulis: %s" % path)
		return
	file.store_var(get_save_data())
	file.close()
	print("[AchievementManager] Achievement tersimpan ke: %s" % path)


## Memuat dari file. Dipanggil oleh SaveGameManager.load_game().
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
