## game_manager.gd  (MODIFIKASI)
## Tambahkan fungsi show_login_screen() dan ubah alur awal game.
extends Node

var game_menu_screen: PackedScene = preload("res://scenes/ui/game_menu_screen.tscn")

# ── Shortcut keyboard untuk membuka game menu ────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_menu"):
		show_game_menu_screen()

# ─────────────────────────────────────────────
# ENTRY POINT BARU: Login Screen
# ─────────────────────────────────────────────

## ⭐ Dipanggil dari Main Scene atau Autoload saat game pertama kali dibuka.
## Menampilkan Login Screen dan menunggu user memilih profil.
func show_login_screen() -> void:
	var login_scene: PackedScene = preload("res://scenes/ui/login_screen.tscn")
	var instance: Node = login_scene.instantiate()
	get_tree().root.add_child(instance)

# ─────────────────────────────────────────────
# GAME FLOW
# ─────────────────────────────────────────────

## Memulai game baru (tidak ada save) untuk user yang sudah login.
func start_game() -> void:
	assert(
		not SaveGameManager.current_username.is_empty(),
		"GameManager.start_game(): User harus login dulu!"
	)

	SceneManager.load_main_scene_container()
	SceneManager.load_level("Level1")

	await get_tree().process_frame

	# Tidak perlu load — ini game baru, data sudah bersih
	SaveGameManager.allow_save_game = true

## Memuat save yang sudah ada untuk user yang sedang login.
func load_saved_game() -> void:
	assert(
		not SaveGameManager.current_username.is_empty(),
		"GameManager.load_saved_game(): User harus login dulu!"
	)

	SceneManager.load_main_scene_container()
	SceneManager.load_level("Level1")

	await get_tree().process_frame

	SaveGameManager.load_game()
	SaveGameManager.allow_save_game = true

# game_manager.gd
# Tambahkan fungsi ini. Fungsi exit_game() dibiarkan seperti aslinya (quit).

## Kembali ke Game Menu (Start/Load/Save) tanpa logout.
## Dipanggil saat Exit dari dalam game — user tetap login.
func return_to_game_menu() -> void:
	# 1. Auto-save sebelum kembali ke menu
	if SaveGameManager.allow_save_game:
		SaveGameManager.save_game()

	# 2. Reset flag save agar tombol "Start" muncul lagi (bukan "Resume")
	SaveGameManager.allow_save_game = false

	# 3. Wajib: matikan pause
	get_tree().paused = false

	# 4. Bersihkan game scene, tapi JANGAN logout
	var main_root_path: String = SceneManager.main_scene_root_path
	if get_tree().root.has_node(main_root_path):
		get_tree().root.get_node(main_root_path).queue_free()
		await get_tree().process_frame

	# 5. Tampilkan Game Menu kembali (user masih login)
	show_game_menu_screen()
	
## Keluar dari game (dengan auto-save).
func exit_game() -> void:
	get_tree().quit()

## Kembali ke layar Login (logout + reset scene).
func return_to_login() -> void:
	SaveGameManager.logout()

	# Bersihkan scene yang ada
	var main_root_path: String = SceneManager.main_scene_root_path
	if get_tree().root.has_node(main_root_path):
		get_tree().root.get_node(main_root_path).queue_free()
		await get_tree().process_frame

	show_login_screen()

# ─────────────────────────────────────────────
# GAME MENU
# ─────────────────────────────────────────────

func show_game_menu_screen() -> void:
	var instance: Node = game_menu_screen.instantiate()
	get_tree().root.add_child(instance)
