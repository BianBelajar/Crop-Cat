## SaveGameManager.gd
## Autoload — mengelola Save/Load dengan dukungan Multi-User Profile.
## Setiap user memiliki folder dan file save yang sepenuhnya terpisah.
extends Node

# ─────────────────────────────────────────────
# SINYAL
# ─────────────────────────────────────────────
## Dipancarkan setelah proses save selesai (berhasil atau gagal).
signal game_saved(success: bool)
## Dipancarkan setelah proses load selesai.
signal game_loaded
## Dipancarkan saat user berpindah profil.
signal user_changed(new_username: String)

# ─────────────────────────────────────────────
# STATE
# ─────────────────────────────────────────────
## Nama user yang sedang aktif. Kosong = belum login.
var current_username: String = "":
	set(value):
		current_username = value
		user_changed.emit(value)

## Apakah game sedang berjalan (digunakan untuk guard tombol Save).
var allow_save_game: bool = false

# ─────────────────────────────────────────────
# KONSTANTA PATH
# ─────────────────────────────────────────────
const BASE_SAVE_DIR: String      = "user://game_data/"
const LEVEL_SAVE_FILE: String    = "save_%s_game_data.tres"
const QUEST_SAVE_FILE: String    = "quest_data.save"

# ─────────────────────────────────────────────
# INPUT SHORTCUT (Tekan P untuk Save)
# ─────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_game") and allow_save_game:
		save_game()

# ─────────────────────────────────────────────
# PATH HELPERS  (semua path bergantung pada username)
# ─────────────────────────────────────────────

## Mengembalikan direktori save milik user yang sedang aktif.
## Contoh: "user://game_data/budi/"
func get_user_save_dir() -> String:
	assert(current_username != "", "SaveGameManager: current_username belum di-set!")
	var safe_name: String = _sanitize_username(current_username)
	return BASE_SAVE_DIR + safe_name + "/"

## Mengembalikan path lengkap file save untuk sebuah level.
## Contoh: "user://game_data/budi/save_Level1_game_data.tres"
func get_level_save_path(level_scene_name: String) -> String:
	return get_user_save_dir() + LEVEL_SAVE_FILE % level_scene_name

## Mengembalikan path file save quest milik user aktif.
func get_quest_save_path() -> String:
	return get_user_save_dir() + QUEST_SAVE_FILE

## Mengecek apakah file save untuk level tertentu sudah ada.
func has_save_for_level(level_scene_name: String) -> bool:
	if current_username.is_empty():
		return false
	return FileAccess.file_exists(get_level_save_path(level_scene_name))

## Mengecek apakah user yang sedang aktif punya data save sama sekali.
func current_user_has_any_save() -> bool:
	return has_save_for_level("Level1")

# ─────────────────────────────────────────────
# SAVE
# ─────────────────────────────────────────────

## Entry point utama untuk menyimpan semua data game.
func save_game() -> void:
	if current_username.is_empty():
		push_error("SaveGameManager.save_game(): Tidak bisa save — user belum login!")
		game_saved.emit(false)
		return

	_ensure_user_dir_exists()

	# 1. Simpan data level (TileMap, posisi player, inventory, dll.)
	var save_level_data_comp: SaveLevelDataComponent = \
		get_tree().get_first_node_in_group("save_level_data_component")

	if save_level_data_comp != null:
		save_level_data_comp.save_game()

	# 2. Simpan data quest (menggunakan path yang di-override)
	QuestManager.save_quest_to_path(get_quest_save_path())

	print("[SaveGameManager] Game tersimpan untuk user: '%s'" % current_username)
	game_saved.emit(true)

# ─────────────────────────────────────────────
# LOAD
# ─────────────────────────────────────────────

## Entry point utama untuk memuat semua data game.
func load_game() -> void:
	if current_username.is_empty():
		push_error("SaveGameManager.load_game(): Tidak bisa load — user belum login!")
		return

	# 1. Muat data quest
	QuestManager.load_quest_from_path(get_quest_save_path())

	# 2. Muat data level
	var save_level_data_comp: SaveLevelDataComponent = \
		get_tree().get_first_node_in_group("save_level_data_component")

	if save_level_data_comp != null:
		save_level_data_comp.load_game()

	print("[SaveGameManager] Game dimuat untuk user: '%s'" % current_username)
	game_loaded.emit()

# ─────────────────────────────────────────────
# PROFILE MANAGEMENT
# ─────────────────────────────────────────────

## Login sebagai user baru. Jika game sedang berjalan, simpan dulu data lama.
func login_as(username: String) -> void:
	var trimmed: String = username.strip_edges()
	if trimmed.is_empty():
		push_warning("SaveGameManager.login_as(): Username tidak boleh kosong.")
		return

	# Simpan data user lama jika game sedang aktif
	if allow_save_game and not current_username.is_empty():
		save_game()

	# Reset state sebelum ganti profil
	allow_save_game = false
	InventoryManager.inventory.clear()
	InventoryManager.inventory_changed.emit()

	current_username = trimmed
	print("[SaveGameManager] Login sebagai: '%s'" % current_username)

## Logout user saat ini (misalnya untuk kembali ke layar login).
func logout() -> void:
	if allow_save_game:
		save_game()
	allow_save_game = false
	current_username = ""
	print("[SaveGameManager] User logout.")

## Mengembalikan daftar username yang sudah pernah membuat save.
func get_existing_profiles() -> Array[String]:
	var profiles: Array[String] = []
	if not DirAccess.dir_exists_absolute(BASE_SAVE_DIR):
		return profiles

	var dir: DirAccess = DirAccess.open(BASE_SAVE_DIR)
	if dir == null:
		return profiles

	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with("."):
			profiles.append(entry)
		entry = dir.get_next()
	dir.list_dir_end()
	return profiles

# ─────────────────────────────────────────────
# PRIVATE HELPERS
# ─────────────────────────────────────────────

func _ensure_user_dir_exists() -> void:
	var path: String = get_user_save_dir()
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)

## Membersihkan karakter ilegal dari username untuk keamanan path.
func _sanitize_username(name: String) -> String:
	var result: String = name.to_lower()
	# Hanya izinkan huruf, angka, strip, underscore
	var regex: RegEx = RegEx.new()
	regex.compile("[^a-z0-9_\\-]")
	result = regex.sub(result, "_", true)
	return result
